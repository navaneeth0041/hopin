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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(
          Icons.check_circle_outline,
          color: AppColors.primaryYellow,
          size: 60,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Join this ride?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re about to join ${ride.driverName}\'s ride',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.accentGreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ride request sent to ${ride.driverName}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.cardBackground,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
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
