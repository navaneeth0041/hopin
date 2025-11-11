import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/trip_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/create_trip_bottom_sheet.dart';
import '../widgets/active_trip_dialog.dart';
import '../utils/trip_dialog_helpers.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
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
      print('Error checking active trip: $e');
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _showCreateTripBottomSheet,
              child: Icon(
                Icons.add_circle,
                size: 80,
                color: AppColors.primaryYellow,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Create Trip',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the icon to start a new trip',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
