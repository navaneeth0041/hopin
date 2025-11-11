import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/trip_provider.dart';
import 'package:hopin/presentation/features/home/widgets/trip_form_field.dart';
import 'package:provider/provider.dart';
import '../widgets/trip_success_dialog.dart';
import '../widgets/seat_selector.dart';
import '../utils/trip_dialog_helpers.dart';

class CreateTripBottomSheet extends StatefulWidget {
  const CreateTripBottomSheet({super.key});

  @override
  State<CreateTripBottomSheet> createState() => _CreateTripBottomSheetState();
}

class _CreateTripBottomSheetState extends State<CreateTripBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentLocationController = TextEditingController();
  final _destinationController = TextEditingController();
  final _departureTimeController = TextEditingController();
  final _noteController = TextEditingController();

  int _availableSeats = 1;
  DateTime? _selectedDateTime;
  bool _isCreating = false;

  @override
  void dispose() {
    _currentLocationController.dispose();
    _destinationController.dispose();
    _departureTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDepartureTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryYellow,
              onPrimary: Colors.black,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.cardBackground,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryYellow,
                onPrimary: Colors.black,
                surface: AppColors.cardBackground,
                onSurface: AppColors.textPrimary,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: AppColors.cardBackground,
                dialBackgroundColor: AppColors.darkBackground,
                dialHandColor: AppColors.primaryYellow,
                dialTextColor: AppColors.textPrimary,
                hourMinuteTextColor: AppColors.textPrimary,
                hourMinuteColor: AppColors.darkBackground,
                dayPeriodTextColor: AppColors.textPrimary,
                dayPeriodColor: AppColors.darkBackground,
                dayPeriodBorderSide: BorderSide(
                  color: AppColors.primaryYellow.withOpacity(0.3),
                ),
                hourMinuteShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                entryModeIconColor: Colors.transparent,
              ),
            ),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            ),
          );
        },
      );

      if (pickedTime != null && mounted) {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        _departureTimeController.text =
            '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} at ${pickedTime.format(context)}';
      }
    }
  }

  Future<void> _handleCreateTrip() async {
    if (_isCreating) return;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateTime == null) {
      TripDialogHelpers.showErrorSnackBar(
        context,
        'Please select departure time',
      );
      return;
    }

    setState(() => _isCreating = true);

    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    try {
      final tripId = await tripProvider.createTrip(
        currentLocation: _currentLocationController.text.trim(),
        destination: _destinationController.text.trim(),
        departureTime: _selectedDateTime!,
        availableSeats: _availableSeats,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (tripId != null && mounted) {
        final String currentLoc = _currentLocationController.text;
        final String dest = _destinationController.text;
        final int seats = _availableSeats;

        final NavigatorState navigator = Navigator.of(context);

        navigator.pop();

        await Future.delayed(const Duration(milliseconds: 500));

        navigator.push(
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: false,
            barrierColor: Colors.black54,
            pageBuilder: (BuildContext context, _, __) {
              return TripSuccessDialog(
                currentLocation: currentLoc,
                destination: dest,
                availableSeats: seats,
              );
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
          ),
        );
      } else if (mounted) {
        setState(() => _isCreating = false);
        TripDialogHelpers.showErrorSnackBar(
          context,
          tripProvider.errorMessage ?? 'Failed to create trip',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        TripDialogHelpers.showErrorSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: const Text(
                  'Post Your Ride',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Details',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TripFormField(
                          controller: _currentLocationController,
                          label: 'Current Location',
                          icon: Icons.my_location,
                          hintText: 'Enter your starting point',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your current location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TripFormField(
                          controller: _destinationController,
                          label: 'Destination',
                          icon: Icons.location_on,
                          hintText: 'Where are you going?',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your destination';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TripFormField(
                          controller: _departureTimeController,
                          label: 'Time of Departure',
                          icon: Icons.schedule,
                          hintText: 'Select date and time',
                          readOnly: true,
                          onTap: _selectDepartureTime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select departure time';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SeatSelector(
                          availableSeats: _availableSeats,
                          onSeatsChanged: (seats) {
                            setState(() => _availableSeats = seats);
                          },
                        ),
                        const SizedBox(height: 16),
                        TripFormField(
                          controller: _noteController,
                          label: 'Optional Note / Fare Estimate',
                          icon: Icons.note_alt_outlined,
                          hintText: 'Add any additional information...',
                          maxLines: 4,
                          required: false,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isCreating ? null : _handleCreateTrip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryYellow,
                              disabledBackgroundColor: AppColors.primaryYellow
                                  .withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isCreating
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Post Ride',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: keyboardHeight > 0 ? 20 : 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
