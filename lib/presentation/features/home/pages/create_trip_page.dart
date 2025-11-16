import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/trip_provider.dart';
import 'package:hopin/data/models/trip.dart';
import 'package:hopin/data/services/enhanced_trip_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/updated_create_trip_bottom_sheet.dart';
import '../widgets/active_trip_dialog.dart';
import '../widgets/my_trip_card.dart';
import '../widgets/trip_detail_bottom_sheet.dart';
import '../utils/trip_dialog_helpers.dart';
import 'trip_requests_screen.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _UpdatedCreateTripPageState();
}

class _UpdatedCreateTripPageState extends State<CreateTripPage> {
  int _selectedTabIndex = 0;
  final EnhancedTripService _enhancedService = EnhancedTripService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      tripProvider.loadUserTrips();
    });
  }

  Future<void> _showCreateTripBottomSheet() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    try {
      final activeTrip = await tripProvider.getActiveUserTrip();

      if (activeTrip != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ActiveTripDialog(
            activeTrip: activeTrip,
            onComplete: () => _handleCompleteTrip(activeTrip.id),
            onCancel: () => _handleCancelTrip(activeTrip.id),
          ),
        );
        return;
      }

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const UpdatedCreateTripBottomSheet(),
        );
      }
    } catch (e) {
      if (mounted) {
        TripDialogHelpers.showErrorSnackBar(
          context,
          'Error checking trips: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _handleCancelTrip(String tripId) async {
    TripDialogHelpers.showLoadingDialog(context, 'Cancelling trip...');

    final success = await _enhancedService.cancelTrip(tripId);

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        TripDialogHelpers.showSuccessDialog(
          context,
          title: 'Trip Cancelled',
          message:
              'Your trip has been cancelled successfully. All members have been notified.',
          icon: Icons.cancel_rounded,
          iconColor: AppColors.accentRed,
          onDismiss: () {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) _showCreateTripBottomSheet();
            });
          },
        );
      } else {
        TripDialogHelpers.showErrorSnackBar(
          context,
          'Failed to cancel trip. Please try again.',
        );
      }
    }
  }

  Future<void> _handleCompleteTrip(String tripId) async {
    TripDialogHelpers.showLoadingDialog(context, 'Marking trip as complete...');

    final success = await _enhancedService.completeTrip(tripId);

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        TripDialogHelpers.showSuccessDialog(
          context,
          title: 'Trip Completed',
          message: 'Great! Your trip has been marked as complete.',
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.accentGreen,
          onDismiss: () {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) _showCreateTripBottomSheet();
            });
          },
        );
      } else {
        TripDialogHelpers.showErrorSnackBar(
          context,
          'Failed to complete trip. Please try again.',
        );
      }
    }
  }

  Future<void> _handleLeaveTrip(Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Leave Trip',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to leave this trip?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final result = await _enhancedService.leaveTrip(trip.id, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success']
                  ? 'You have left the trip'
                  : result['error'] ?? 'Failed to leave trip',
            ),
            backgroundColor: result['success']
                ? AppColors.accentGreen
                : AppColors.accentRed,
          ),
        );
      }
    }
  }

  List<Trip> _getFilteredTrips(
    List<Trip> createdTrips,
    List<Trip> joinedTrips,
  ) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    switch (_selectedTabIndex) {
      case 0:
        final activeCreated = createdTrips
            .where(
              (trip) =>
                  trip.status == TripStatus.active ||
                  trip.status == TripStatus.full,
            )
            .toList();

        final activeJoined = joinedTrips
            .where(
              (trip) =>
                  trip.status == TripStatus.active ||
                  trip.status == TripStatus.full,
            )
            .toList();

        return [...activeCreated, ...activeJoined]
          ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

      case 1:
        final historyCreated = createdTrips
            .where(
              (trip) =>
                  trip.status == TripStatus.completed ||
                  trip.status == TripStatus.cancelled,
            )
            .toList();

        final historyJoined = joinedTrips
            .where(
              (trip) =>
                  trip.status == TripStatus.completed ||
                  trip.status == TripStatus.cancelled,
            )
            .toList();

        return [...historyCreated, ...historyJoined]
          ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

      default:
        return [];
    }
  }

  void _showTripDetails(Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TripDetailBottomSheet(trip: trip),
    );
  }

  void _showTripRequests(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripRequestsScreen(tripId: trip.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabSelector(),
            Expanded(
              child: Consumer<TripProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryYellow,
                      ),
                    );
                  }

                  final filteredTrips = _getFilteredTrips(
                    provider.myCreatedTrips,
                    provider.myJoinedTrips,
                  );

                  if (filteredTrips.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await provider.loadUserTrips();
                    },
                    color: AppColors.primaryYellow,
                    backgroundColor: AppColors.cardBackground,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                      itemCount: filteredTrips.length,
                      itemBuilder: (context, index) {
                        final trip = filteredTrips[index];
                        final isCreator = trip.createdBy == userId;
                        final isActive =
                            trip.status == TripStatus.active ||
                            trip.status == TripStatus.full;

                        return _TripCardWithActions(
                          trip: trip,
                          isCreator: isCreator,
                          onCancel: isCreator && isActive
                              ? () => _handleCancelTrip(trip.id)
                              : null,
                          onComplete: isCreator && isActive
                              ? () => _handleCompleteTrip(trip.id)
                              : null,
                          onLeave: !isCreator && isActive
                              ? () => _handleLeaveTrip(trip)
                              : null,
                          onViewDetails: () => _showTripDetails(trip),
                          onViewRequests: isCreator && isActive
                              ? () => _showTripRequests(trip)
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 44),
          const Text(
            'My Trips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: _showCreateTripBottomSheet,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primaryYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [_buildTab('Active', 0), _buildTab('History', 1)]),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_selectedTabIndex) {
      case 0:
        message = 'No active trips';
        icon = Icons.directions_car_outlined;
        break;
      case 1:
        message = 'No trip history';
        icon = Icons.history;
        break;
      default:
        message = 'No trips found';
        icon = Icons.search_off;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCardWithActions extends StatelessWidget {
  final Trip trip;
  final bool isCreator;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;
  final VoidCallback? onLeave;
  final VoidCallback onViewDetails;
  final VoidCallback? onViewRequests;

  const _TripCardWithActions({
    required this.trip,
    required this.isCreator,
    this.onCancel,
    this.onComplete,
    this.onLeave,
    required this.onViewDetails,
    this.onViewRequests,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: MyTripCard(
        trip: trip,
        onCancel: onCancel,
        onComplete: onComplete,
        onViewDetails: onViewDetails,
        showRequestsButton: isCreator && onViewRequests != null,
        onViewRequests: onViewRequests,
        showLeaveButton: !isCreator && onLeave != null,
        onLeave: onLeave,
      ),
    );
  }
}
