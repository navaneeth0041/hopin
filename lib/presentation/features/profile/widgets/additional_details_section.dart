// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/presentation/common_widgets/custom_text_field.dart';
import 'package:hopin/presentation/features/profile/widgets/section_header.dart';
import 'package:hopin/presentation/features/profile/widgets/field_label.dart';
import 'package:intl/intl.dart';

class AdditionalDetailsSection extends StatelessWidget {
  final String? selectedGender;
  final DateTime? selectedDateOfBirth;
  final TextEditingController departmentController;
  final TextEditingController yearController;
  final TextEditingController hostelController;
  final TextEditingController roomNumberController;
  final TextEditingController hometownController;
  final TextEditingController bioController;
  final Function(String?) onGenderChanged;
  final Function(DateTime?) onDateOfBirthChanged;
  final Function(String?) onYearChanged;

  const AdditionalDetailsSection({
    super.key,
    required this.selectedGender,
    required this.selectedDateOfBirth,
    required this.departmentController,
    required this.yearController,
    required this.hostelController,
    required this.roomNumberController,
    required this.hometownController,
    required this.bioController,
    required this.onGenderChanged,
    required this.onDateOfBirthChanged,
    required this.onYearChanged,
  });

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
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

    if (picked != null && picked != selectedDateOfBirth) {
      onDateOfBirthChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Additional Details'),
        
        // Gender
        const FieldLabel(label: 'Gender', required: false),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGender,
              hint: const Text(
                'Select Gender',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              isExpanded: true,
              dropdownColor: AppColors.cardBackground,
              style: const TextStyle(color: AppColors.textPrimary),
              items: ['Male', 'Female', 'Other', 'Prefer not to say']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: onGenderChanged,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Date of Birth
        const FieldLabel(label: 'Date of Birth', required: false),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDateOfBirth(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDateOfBirth != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDateOfBirth!)
                      : 'Select Date',
                  style: TextStyle(
                    color: selectedDateOfBirth != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Department
        const FieldLabel(label: 'Department', required: false),
        const SizedBox(height: 8),
        CustomTextField(
          controller: departmentController,
          hintText: 'Computer Science',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20),
        
        // Year
        const FieldLabel(label: 'Year', required: false),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: yearController.text.isEmpty ? null : yearController.text,
              hint: const Text(
                'Select Year',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              isExpanded: true,
              dropdownColor: AppColors.cardBackground,
              style: const TextStyle(color: AppColors.textPrimary),
              items: ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year']
                  .map((year) => DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      ))
                  .toList(),
              onChanged: onYearChanged,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Hostel
        const FieldLabel(label: 'Hostel', required: false),
        const SizedBox(height: 8),
        CustomTextField(
          controller: hostelController,
          hintText: 'Hostel Name',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20),
        
        // Room Number
        const FieldLabel(label: 'Room Number', required: false),
        const SizedBox(height: 8),
        CustomTextField(
          controller: roomNumberController,
          hintText: '201',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20),
        
        // Hometown
        const FieldLabel(label: 'Hometown', required: false),
        const SizedBox(height: 8),
        CustomTextField(
          controller: hometownController,
          hintText: 'City, State',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20),
        
        // Bio
        const FieldLabel(label: 'Bio', required: false),
        const SizedBox(height: 8),
        CustomTextField(
          controller: bioController,
          hintText: 'Tell us about yourself...',
          keyboardType: TextInputType.multiline,
          maxLines: 4,
        ),
      ],
    );
  }
}