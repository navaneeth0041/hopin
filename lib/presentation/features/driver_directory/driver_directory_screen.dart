// ignore_for_file: deprecated_member_use

import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/home/driver_model.dart';
import 'package:hopin/data/services/driver_service.dart';
import 'package:hopin/presentation/common_widgets/custom_button.dart';
import 'package:hopin/presentation/common_widgets/custom_text_field.dart';
import 'widgets/driver_card.dart';
import 'widgets/driver_filter_chip.dart';

class DriverDirectoryScreen extends StatefulWidget {
  const DriverDirectoryScreen({super.key});

  @override
  State<DriverDirectoryScreen> createState() => _DriverDirectoryScreenState();
}

class _DriverDirectoryScreenState extends State<DriverDirectoryScreen> {
  final DriverService _driverService = DriverService();
  String selectedFilter = 'all';
  String searchQuery = '';
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _areaController = TextEditingController();
  String _newDriverType = 'auto';

  // Form Key for Validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleNoController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  // ---- COOLER UI BOTTOM SHEET WITH FIREBASE INTEGRATION ----
  void _showAddDriverBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Important for the blur effect
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: AppColors.primaryYellow.withOpacity(0.3), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Driver',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fill in the driver details below',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('Full Name'),
                              CustomTextField(
                                controller: _nameController,
                                hintText: 'Enter driver name',
                                textCapitalization: TextCapitalization.words,
                                suffixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Driver name is required';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'Name must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              _buildInputLabel('Phone Number'),
                              CustomTextField(
                                controller: _phoneController,
                                hintText: '9876543210',
                                keyboardType: TextInputType.phone,
                                suffixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  // Regex: 10 digits starting with 6-9. No symbols.
                                  final strictPhoneRegex = RegExp(r'^[6-9]\d{9}$');
                                  
                                  if (!strictPhoneRegex.hasMatch(value)) {
                                    return 'Invalid format. Enter 10 digits starting with 6-9\n(e.g., 9876543210)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              _buildInputLabel('Vehicle Type'),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSelectionCard(
                                      label: 'Auto Rickshaw',
                                      icon: Icons.airport_shuttle,
                                      isSelected: _newDriverType == 'auto',
                                      onTap: () => setSheetState(() => _newDriverType = 'auto'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildSelectionCard(
                                      label: 'Taxi / Car',
                                      icon: Icons.local_taxi,
                                      isSelected: _newDriverType == 'taxi',
                                      onTap: () => setSheetState(() => _newDriverType = 'taxi'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              _buildInputLabel('Vehicle Number'),
                              CustomTextField(
                                controller: _vehicleNoController,
                                hintText: 'KL-01-AB-1234',
                                textCapitalization: TextCapitalization.characters,
                                suffixIcon: Icon(Icons.confirmation_number_outlined, color: AppColors.textSecondary),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vehicle number is required';
                                  }
                                  // Regex for Indian Vehicle Numbers
                                  final vehicleRegex = RegExp(r'^[A-Z]{2}[ -]?[0-9]{1,2}[ -]?[A-Z]{1,3}[ -]?[0-9]{4}$');
                                  
                                  if (!vehicleRegex.hasMatch(value.toUpperCase())) {
                                    return 'Invalid format.\nUse format like: KL-07-AB-1234 or KL07AB1234';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              _buildInputLabel('Operating Area'),
                              CustomTextField(
                                controller: _areaController,
                                hintText: 'e.g. Amritapuri, Karunagappally',
                                textCapitalization: TextCapitalization.words,
                                suffixIcon: Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Operating area is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              
                              CustomButton(
                                text: 'Add Driver',
                                onPressed: () => _submitNewDriver(context),
                                showArrow: true,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryYellow.withOpacity(0.15) 
              : AppColors.darkBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellow : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryYellow : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryYellow : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitNewDriver(BuildContext sheetContext) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Create the driver object
      // We manually add the +91 prefix here before sending to Firebase
      // to maintain consistency with the hardcoded data format
      final newDriver = Driver(
        id: '', // Empty ID, Firestore will generate one
        name: _nameController.text.trim(),
        phoneNumber: '+91 ${_phoneController.text.trim()}',
        vehicleType: _newDriverType,
        vehicleNumber: _vehicleNoController.text.trim().toUpperCase(),
        area: _areaController.text.trim(),
        rating: 0.0,
        isVerified: true, // Auto-verify for testing visibility
      );

      // Call the service to add to Firebase
      await _driverService.addDriver(newDriver);
      
      if (mounted) {
        Navigator.pop(sheetContext);
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver added to database successfully!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding driver: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _vehicleNoController.clear();
    _areaController.clear();
    _newDriverType = 'auto';
  }

  List<Driver> _filterDrivers(List<Driver> allDrivers) {
    return allDrivers.where((driver) {
      if (selectedFilter != 'all' && driver.vehicleType != selectedFilter) {
        return false;
      }
      
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return driver.name.toLowerCase().contains(query) ||
            driver.vehicleNumber.toLowerCase().contains(query) ||
            driver.area.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDriverBottomSheet,
        backgroundColor: AppColors.primaryYellow,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Driver Directory',
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Search drivers, vehicles, or areas...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  DriverFilterChip(
                    label: 'All',
                    icon: Icons.grid_view,
                    isSelected: selectedFilter == 'all',
                    onTap: () => setState(() => selectedFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  DriverFilterChip(
                    label: 'Auto',
                    icon: Icons.airport_shuttle,
                    isSelected: selectedFilter == 'auto',
                    onTap: () => setState(() => selectedFilter = 'auto'),
                  ),
                  const SizedBox(width: 8),
                  DriverFilterChip(
                    label: 'Taxi',
                    icon: Icons.local_taxi,
                    isSelected: selectedFilter == 'taxi',
                    onTap: () => setState(() => selectedFilter = 'taxi'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: StreamBuilder<List<Driver>>(
                stream: _driverService.getVerifiedDrivers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow));
                  }
                  
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading drivers', style: TextStyle(color: AppColors.textSecondary)));
                  }

                  // Data comes in pre-filtered for 'Verified Only' by the Service
                  final allVerifiedDrivers = snapshot.data ?? [];
                  final drivers = _filterDrivers(allVerifiedDrivers);

                  if (drivers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Drivers Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: drivers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return DriverCard(driver: drivers[index], onTap: () {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}