import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/trip_provider.dart';
import 'package:hopin/data/models/trip.dart';
import 'package:provider/provider.dart';
import '../widgets/create_trip_bottom_sheet.dart';
import '../widgets/active_trip_dialog.dart';
import '../widgets/my_trip_card.dart';
import '../widgets/trip_detail_bottom_sheet.dart';
import '../utils/trip_dialog_helpers.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  int _selectedTabIndex = 0;

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
          builder: (context) => const CreateTripBottomSheet(),
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

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final success = await tripProvider.cancelTrip(tripId);

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        TripDialogHelpers.showSuccessDialog(
          context,
          title: 'Trip Cancelled',
          message:
              'Your trip has been cancelled successfully. You can now create a new trip.',
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

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final success = await tripProvider.completeTrip(tripId);

    if (mounted) {
      Navigator.pop(context);

      if (success) {
        TripDialogHelpers.showSuccessDialog(
          context,
          title: 'Trip Completed',
          message:
              'Great! Your trip has been marked as complete. Ready to create a new one?',
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

  List<Trip> _getFilteredTrips(List<Trip> trips) {
    switch (_selectedTabIndex) {
      case 0:
        return trips
            .where(
              (trip) =>
                  trip.status == TripStatus.active ||
                  trip.status == TripStatus.full,
            )
            .toList();
      case 1:
        return trips
            .where((trip) => trip.status == TripStatus.completed)
            .toList();
      case 2:
        return trips
            .where((trip) => trip.status == TripStatus.cancelled)
            .toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabSelector(),
            Expanded(child: _buildTripsList()),
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
              decoration: BoxDecoration(
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
        child: Row(
          children: [
            _buildTab('Active', 0),
            _buildTab('Completed', 1),
            _buildTab('Cancelled', 2),
          ],
        ),
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

  Widget _buildTripsList() {
    return Consumer<TripProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryYellow),
          );
        }

        final filteredTrips = _getFilteredTrips(provider.myCreatedTrips);

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
              return MyTripCard(
                trip: trip,
                onCancel: () => _handleCancelTrip(trip.id),
                onComplete: () => _handleCompleteTrip(trip.id),
                onViewDetails: () => _showTripDetails(trip),
              );
            },
          ),
        );
      },
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
        message = 'No completed trips';
        icon = Icons.check_circle_outline;
        break;
      case 2:
        message = 'No cancelled trips';
        icon = Icons.cancel_outlined;
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
