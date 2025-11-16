import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/services/enhanced_trip_service.dart';
import 'package:hopin/presentation/features/home/pages/location_picker_screen.dart';
import 'package:hopin/presentation/features/home/widgets/trip_form_field.dart';
import 'package:hopin/presentation/features/home/widgets/trip_success_dialog.dart';
import 'package:hopin/presentation/features/home/widgets/seat_selector.dart';
import 'package:hopin/presentation/features/home/utils/trip_dialog_helpers.dart';
import 'package:latlong2/latlong.dart';

class UpdatedCreateTripBottomSheet extends StatefulWidget {
  const UpdatedCreateTripBottomSheet({super.key});

  @override
  State<UpdatedCreateTripBottomSheet> createState() => _UpdatedCreateTripBottomSheetState();
}

class _UpdatedCreateTripBottomSheetState extends State<UpdatedCreateTripBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentLocationController = TextEditingController();
  final _destinationController = TextEditingController();
  final _departureTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _noteController = TextEditingController();

  final EnhancedTripService _tripService = EnhancedTripService();

  int _availableSeats = 1;
  DateTime? _selectedDepartureTime;
  DateTime? _selectedEndTime;
  LatLng? _currentLocationCoords;
  LatLng? _destinationCoords;
  String _currentLocationAddress = '';
  String _destinationAddress = '';
  bool _isCreating = false;

  @override
  void dispose() {
    _currentLocationController.dispose();
    _destinationController.dispose();
    _departureTimeController.dispose();
    _endTimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectCurrentLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _currentLocationCoords,
          title: 'Select Pickup Location',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentLocationCoords = result['location'] as LatLng;
        _currentLocationAddress = result['address'] as String;
        _currentLocationController.text = _currentLocationAddress;
      });
    }
  }

  Future<void> _selectDestination() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _destinationCoords,
          title: 'Select Destination',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _destinationCoords = result['location'] as LatLng;
        _destinationAddress = result['address'] as String;
        _destinationController.text = _destinationAddress;
      });
    }
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
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        _selectedDepartureTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        _departureTimeController.text =
            '${_selectedDepartureTime!.day}/${_selectedDepartureTime!.month}/${_selectedDepartureTime!.year} at ${pickedTime.format(context)}';
      }
    }
  }

  Future<void> _selectEndTime() async {
    if (_selectedDepartureTime == null) {
      TripDialogHelpers.showErrorSnackBar(
        context,
        'Please select departure time first',
      );
      return;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDepartureTime!,
      firstDate: _selectedDepartureTime!,
      lastDate: _selectedDepartureTime!.add(const Duration(days: 1)),
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
        initialTime: TimeOfDay.fromDateTime(
          _selectedDepartureTime!.add(const Duration(hours: 2)),
        ),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryYellow,
                onPrimary: Colors.black,
                surface: AppColors.cardBackground,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        _selectedEndTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (_selectedEndTime!.isBefore(_selectedDepartureTime!) ||
            _selectedEndTime!.isAtSameMomentAs(_selectedDepartureTime!)) {
          TripDialogHelpers.showErrorSnackBar(
            context,
            'End time must be after departure time',
          );
          _selectedEndTime = null;
          _endTimeController.clear();
          return;
        }

        _endTimeController.text =
            '${_selectedEndTime!.day}/${_selectedEndTime!.month}/${_selectedEndTime!.year} at ${pickedTime.format(context)}';
      }
    }
  }

  Future<void> _handleCreateTrip() async {
    if (_isCreating) return;

    if (!_formKey.currentState!.validate()) return;

    if (_currentLocationCoords == null) {
      TripDialogHelpers.showErrorSnackBar(
        context,
        'Please select pickup location',
      );
      return;
    }

    if (_destinationCoords == null) {
      TripDialogHelpers.showErrorSnackBar(
        context,
        'Please select destination',
      );
      return;
    }

    if (_selectedDepartureTime == null) {
      TripDialogHelpers.showErrorSnackBar(
        context,
        'Please select departure time',
      );
      return;
    }

    if (_selectedEndTime == null) {
      TripDialogHelpers.showErrorSnackBar(
        context,
        'Please select end time',
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final result = await _tripService.createTrip(
        currentLocation: _currentLocationAddress,
        currentLat: _currentLocationCoords!.latitude,
        currentLng: _currentLocationCoords!.longitude,
        destination: _destinationAddress,
        destLat: _destinationCoords!.latitude,
        destLng: _destinationCoords!.longitude,
        departureTime: _selectedDepartureTime!,
        endTime: _selectedEndTime!,
        availableSeats: _availableSeats,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (result['success'] && mounted) {
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
                currentLocation: _currentLocationAddress,
                destination: _destinationAddress,
                availableSeats: _availableSeats,
              );
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
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
          result['error'] ?? 'Failed to create trip',
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
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
                          label: 'Pickup Location',
                          icon: Icons.my_location,
                          hintText: 'Tap to select on map',
                          readOnly: true,
                          onTap: _selectCurrentLocation,
                          validator: (value) {
                            if (_currentLocationCoords == null) {
                              return 'Please select pickup location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TripFormField(
                          controller: _destinationController,
                          label: 'Destination',
                          icon: Icons.location_on,
                          hintText: 'Tap to select on map',
                          readOnly: true,
                          onTap: _selectDestination,
                          validator: (value) {
                            if (_destinationCoords == null) {
                              return 'Please select destination';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TripFormField(
                          controller: _departureTimeController,
                          label: 'Departure Time',
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
                        const SizedBox(height: 16),
                        
                        TripFormField(
                          controller: _endTimeController,
                          label: 'Expected End Time',
                          icon: Icons.access_time,
                          hintText: 'Select expected arrival time',
                          readOnly: true,
                          onTap: _selectEndTime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select end time';
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
                          label: 'Optional Note',
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
                              disabledBackgroundColor: 
                                  AppColors.primaryYellow.withOpacity(0.6),
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