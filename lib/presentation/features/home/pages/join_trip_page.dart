import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/trip.dart';
import 'package:hopin/data/providers/trip_provider.dart';
import 'package:hopin/data/providers/blocked_users_provider.dart';
import 'package:hopin/data/services/trip_request_service.dart';
import 'package:hopin/data/services/trip_validation_service.dart';
import 'package:hopin/presentation/features/home/utils/trip_dialog_helpers.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/ride_card.dart';
import '../widgets/ride_detail_bottom_sheet.dart';
import '../widgets/filter_chips.dart';
import '../widgets/filter_bottom_sheet.dart';

class JoinTripPage extends StatefulWidget {
  const JoinTripPage({super.key});

  @override
  State<JoinTripPage> createState() => _JoinTripPageState();
}

class _JoinTripPageState extends State<JoinTripPage> {
  List<Trip> filteredRides = [];
  String selectedTimeFilter = 'All';
  RideFilterOptions advancedFilters = RideFilterOptions();
  String? currentUserId;
  final TripRequestService _requestService = TripRequestService();
  final TripValidationService _validationService = TripValidationService();
  Set<String> _requestedTripIds = {};

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadPendingRequests();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
      _loadBlockedUsers();
    });
  }

  void _loadPendingRequests() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _requestService.getUserPendingRequests(userId).listen((requests) {
        setState(() {
          _requestedTripIds = requests.map((r) => r.tripId).toSet();
        });
      });
    }
  }

  void _loadTrips() {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    tripProvider.loadActiveTrips();
  }

  Future<void> _loadBlockedUsers() async {
    final blockedProvider = Provider.of<BlockedUsersProvider>(
      context,
      listen: false,
    );
    await blockedProvider.loadBlockedUsers();
  }

  List<Trip> _getFilteredTrips(List<Trip> allTrips) {
    if (currentUserId == null) return [];

    List<Trip> userFilteredTrips = allTrips.where((trip) {
      if (trip.createdBy == currentUserId) return false;
      if (trip.joinedUsers.contains(currentUserId)) return false;
      return true;
    }).toList();

    List<Trip> timeFiltered = userFilteredTrips.where((trip) {
      return _matchesTimeFilter(trip);
    }).toList();

    List<Trip> advancedFiltered = timeFiltered.where((trip) {
      if (advancedFilters.minSeats != null) {
        if (trip.availableSeats < advancedFilters.minSeats!) return false;
      }
      return true;
    }).toList();

    if (advancedFilters.sortBy != null) {
      _applySorting(advancedFiltered);
    }

    return advancedFiltered;
  }

  bool _matchesTimeFilter(Trip trip) {
    try {
      final rideDate = trip.departureTime;
      final now = DateTime.now();

      switch (selectedTimeFilter) {
        case 'Today':
          return rideDate.year == now.year &&
              rideDate.month == now.month &&
              rideDate.day == now.day;

        case 'This Week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          return rideDate.isAfter(
                startOfWeek.subtract(const Duration(days: 1)),
              ) &&
              rideDate.isBefore(endOfWeek.add(const Duration(days: 1)));
        case 'All':
        default:
          return true;
      }
    } catch (e) {
      return true;
    }
  }

  void _applySorting(List<Trip> trips) {
    switch (advancedFilters.sortBy) {
      case 'Time: Earliest First':
        trips.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case 'Time: Latest First':
        trips.sort((a, b) => b.departureTime.compareTo(a.departureTime));
        break;
      case 'Seats: Most Available':
        trips.sort((a, b) => b.availableSeats.compareTo(a.availableSeats));
        break;
    }
  }

  void _onTimeFilterSelected(String filter) {
    setState(() {
      selectedTimeFilter = filter;
    });
  }

  void _showAdvancedFilters() async {
    final result = await showModalBottomSheet<RideFilterOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(currentFilters: advancedFilters),
    );

    if (result != null) {
      setState(() {
        advancedFilters = result;
      });
    }
  }

  void _showRideDetails(Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RideDetailBottomSheet(trip: trip),
    );
  }

  void _handleJoinRide(Trip trip) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      TripDialogHelpers.showErrorSnackBar(
        context,
        'You must be logged in to join trips',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      ),
    );

    final validation = await _validationService.canJoinTrip(
      userId: userId,
      tripId: trip.id,
    );

    if (mounted) Navigator.pop(context);

    if (!validation['valid']) {
      if (mounted) {
        TripDialogHelpers.showErrorSnackBar(
          context,
          validation['error'] ?? 'Cannot join this trip',
        );
      }
      return;
    }

    String noteText = '';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final TextEditingController noteController = TextEditingController();

        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Send Join Request',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send a request to join ${trip.creatorName}\'s trip?',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  maxLength: 150,
                  onChanged: (value) {
                    noteText = value;
                  },
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a message (optional)',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: AppColors.darkBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
              ),
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      final requestResult = await _requestService.createTripRequest(
        tripId: trip.id,
        message: noteText.isEmpty ? null : noteText,
      );

      if (mounted) {
        if (requestResult['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Request sent successfully!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          TripDialogHelpers.showErrorSnackBar(
            context,
            requestResult['error'] ?? 'Failed to send request',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TripProvider, BlockedUsersProvider>(
      builder: (context, tripProvider, blockedProvider, child) {
        final blockedUserIds = blockedProvider.blockedUsers
            .map((user) => user.uid)
            .toSet();

        final tripsExcludingBlocked = tripProvider.activeTrips
            .where((trip) => !blockedUserIds.contains(trip.createdBy))
            .toList();

        filteredRides = _getFilteredTrips(tripsExcludingBlocked);

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 44),
                    const Text(
                      'Available Rides',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${filteredRides.length} rides',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilterChips(
                  selectedFilter: selectedTimeFilter,
                  onFilterSelected: _onTimeFilterSelected,
                  onMoreFilters: _showAdvancedFilters,
                ),
              ),

              if (advancedFilters.hasActiveFilters)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryYellow.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_alt,
                        size: 16,
                        color: AppColors.primaryYellow,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getActiveFiltersText(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            advancedFilters = RideFilterOptions();
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: tripProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryYellow,
                        ),
                      )
                    : filteredRides.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: filteredRides.length,
                        itemBuilder: (context, index) {
                          final trip = filteredRides[index];
                          return RideCard(
                            trip: trip,
                            onJoinRide: () => _handleJoinRide(trip),
                            onViewDetails: () => _showRideDetails(trip),
                            hasRequestedJoin: _requestedTripIds.contains(
                              trip.id,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getActiveFiltersText() {
    List<String> filters = [];

    if (advancedFilters.minSeats != null) {
      filters.add('${advancedFilters.minSeats}+ seats');
    }
    if (advancedFilters.sortBy != null) {
      filters.add(advancedFilters.sortBy!);
    }

    return filters.isEmpty
        ? 'Active filters'
        : 'Active filters: ${filters.join(' • ')}';
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 120.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Rides Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedTimeFilter = 'All';
                  advancedFilters = RideFilterOptions();
                });
              },
              child: const Text(
                'Clear All Filters',
                style: TextStyle(
                  color: AppColors.primaryYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
