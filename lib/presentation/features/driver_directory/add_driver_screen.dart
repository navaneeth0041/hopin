
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/presentation/common_widgets/custom_text_field.dart';
import 'package:hopin/presentation/common_widgets/custom_button.dart';

class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({super.key});

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _areaController = TextEditingController();
  
  String _selectedVehicleType = 'auto';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleNumberController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _submitDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Add Firebase logic here to save driver
      // Example:
      // await FirebaseFirestore.instance.collection('drivers').add({
      //   'name': _nameController.text,
      //   'phoneNumber': _phoneController.text,
      //   'vehicleType': _selectedVehicleType,
      //   'vehicleNumber': _vehicleNumberController.text,
      //   'area': _areaController.text,
      //   'isVerified': false, // Default: not verified
      //   'createdAt': FieldValue.serverTimestamp(),
      // });
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Driver added! Awaiting admin verification.'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Add New Driver',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // FORM
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // INFO BOX
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryYellow.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primaryYellow,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Driver will be unverified by default. Admin must verify in Firebase to show in directory.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // DRIVER NAME
                      Text(
                        'Driver Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Enter driver name',
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter driver name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // PHONE NUMBER
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: '+91 XXXXX XXXXX',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (value.length < 10) {
                            return 'Please enter valid phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // VEHICLE TYPE
                      Text(
                        'Vehicle Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildVehicleTypeOption(
                              'Auto',
                              'auto',
                              Icons.airport_shuttle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildVehicleTypeOption(
                              'Taxi',
                              'taxi',
                              Icons.local_taxi,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // VEHICLE NUMBER
                      Text(
                        'Vehicle Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _vehicleNumberController,
                        hintText: 'KL-07 AB 1234',
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter vehicle number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // AREA
                      Text(
                        'Area',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
CustomTextField(
controller: _areaController,
hintText: 'Enter area/locality',
textCapitalization: TextCapitalization.words,
validator: (value) {
if (value == null || value.isEmpty) {
return 'Please enter area';
}
return null;
},
),
                  const SizedBox(height: 40),

                  // SUBMIT BUTTON
                  CustomButton(
                    text: _isLoading ? 'Adding Driver...' : 'Add Driver',
                    onPressed: _isLoading ? () {} : _submitDriver,
                    showArrow: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
}
Widget _buildVehicleTypeOption(String label, String value, IconData icon) {
final isSelected = _selectedVehicleType == value;
return GestureDetector(
onTap: () {
setState(() {
_selectedVehicleType = value;
});
},
child: Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: isSelected
? AppColors.primaryYellow.withOpacity(0.15)
: AppColors.cardBackground,
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: isSelected
? AppColors.primaryYellow
: AppColors.divider,
width: 1.5,
),
),
child: Column(
children: [
Icon(
icon,
color: isSelected
? AppColors.primaryYellow
: AppColors.textSecondary,
size: 32,
),
const SizedBox(height: 8),
Text(
label,
style: TextStyle(
fontSize: 14,
fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
color: isSelected
? AppColors.textPrimary
: AppColors.textSecondary,
),
),
],
),
),
);
}
}