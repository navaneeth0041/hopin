import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/home/ride_model.dart';
import '../widgets/ride_card.dart';
import '../widgets/ride_detail_bottom_sheet.dart';
import '../widgets/filter_chips.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'package:intl/intl.dart';

class JoinTripPage extends StatefulWidget {
  const JoinTripPage({super.key});

  @override
  State<JoinTripPage> createState() => _JoinTripPageState();
}

class _JoinTripPageState extends State<JoinTripPage> {
  List<RideModel> availableRides = RideModelMockData.getMockRides();
  List<RideModel> filteredRides = [];
  String selectedTimeFilter = 'All';
  RideFilterOptions advancedFilters = RideFilterOptions();

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      filteredRides = availableRides.where((ride) {
        if (!_matchesTimeFilter(ride)) return false;

        if (advancedFilters.priceRange != null) {
          if (!_matchesPriceRange(ride)) return false;
        }

        if (advancedFilters.minSeats != null) {
          if (ride.availableSeats < advancedFilters.minSeats!) return false;
        }

        return true;
      }).toList();

      if (advancedFilters.sortBy != null) {
        _applySorting();
      }
    });
  }

  bool _matchesTimeFilter(RideModel ride) {
    try {
      final dateFormat = DateFormat('d MMM yyyy');
      final rideDate = dateFormat.parse(ride.date);
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

  bool _matchesPriceRange(RideModel ride) {
    try {
      final priceStr = ride.price.replaceAll(RegExp(r'[^\d.]'), '');
      final price = double.parse(priceStr);

      switch (advancedFilters.priceRange) {
        case 'Under ₹50':
          return price < 50;
        case '₹50 - ₹100':
          return price >= 50 && price <= 100;
        case '₹100 - ₹200':
          return price > 100 && price <= 200;
        case 'Above ₹200':
          return price > 200;
        default:
          return true;
      }
    } catch (e) {
      return true;
    }
  }

  void _applySorting() {
    switch (advancedFilters.sortBy) {
      case 'Price: Low to High':
        filteredRides.sort((a, b) {
          final priceA =
              double.tryParse(a.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          final priceB =
              double.tryParse(b.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'Price: High to Low':
        filteredRides.sort((a, b) {
          final priceA =
              double.tryParse(a.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          final priceB =
              double.tryParse(b.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'Time: Earliest First':
        filteredRides.sort(
          (a, b) => _parseTime(a.time).compareTo(_parseTime(b.time)),
        );
        break;
      case 'Time: Latest First':
        filteredRides.sort(
          (a, b) => _parseTime(b.time).compareTo(_parseTime(a.time)),
        );
        break;
      case 'Seats: Most Available':
        filteredRides.sort(
          (a, b) => b.availableSeats.compareTo(a.availableSeats),
        );
        break;
    }
  }

  int _parseTime(String timeStr) {
    try {
      final format = DateFormat('h:mm a');
      final time = format.parse(timeStr);
      return time.hour * 60 + time.minute;
    } catch (e) {
      return 0;
    }
  }

  void _onTimeFilterSelected(String filter) {
    setState(() {
      selectedTimeFilter = filter;
      _applyFilters();
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
        _applyFilters();
      });
    }
  }

  void _showRideDetails(RideModel ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RideDetailBottomSheet(ride: ride),
    );
  }

  void _handleJoinRide(RideModel ride) {
    String noteText = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        final TextEditingController noteController = TextEditingController();

        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.primaryYellow,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Join Ride',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'You\'re requesting to join '),
                        TextSpan(
                          text: ride.driverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const TextSpan(text: '\'s ride'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.my_location,
                              size: 16,
                              color: AppColors.primaryYellow,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'From',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ride.from,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const SizedBox(width: 18),
                            Container(
                              width: 2,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.primaryYellow.withOpacity(0.3),
                                    AppColors.accentGreen.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.accentGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'To',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ride.to,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.message,
                        color: AppColors.accentBlue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Add a message',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(optional)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                    hintText:
                        'e.g., "I have 2 luggage bags" or "Running 5 mins late"',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AppColors.darkBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryYellow,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    counterStyle: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.divider, width: 1),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.accentGreen,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Request sent to ${ride.driverName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.cardBackground,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Send Request',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 16,
            20,
            12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Rides',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      _applyFilters();
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
          child: filteredRides.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: filteredRides.length,
                  itemBuilder: (context, index) {
                    final ride = filteredRides[index];
                    return RideCard(
                      ride: ride,
                      onJoinRide: () => _handleJoinRide(ride),
                      onViewDetails: () => _showRideDetails(ride),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _getActiveFiltersText() {
    List<String> filters = [];

    if (advancedFilters.priceRange != null) {
      filters.add(advancedFilters.priceRange!);
    }
    if (advancedFilters.minSeats != null) {
      filters.add('${advancedFilters.minSeats}+ seats');
    }
    if (advancedFilters.sortBy != null) {
      filters.add(advancedFilters.sortBy!);
    }

    return 'Active filters: ${filters.join(' • ')}';
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
                  _applyFilters();
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
