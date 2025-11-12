import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopin/presentation/common_widgets/custom_text_field.dart';
import 'package:hopin/presentation/features/profile/widgets/section_header.dart';
import 'package:hopin/presentation/features/profile/widgets/field_label.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController studentIdController;
  final TextEditingController phoneController;
  final VoidCallback onFieldChanged;

  const BasicInfoSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.studentIdController,
    required this.phoneController,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Basic Information'),
        const FieldLabel(label: 'Full Name', required: true),
        const SizedBox(height: 8),
        CustomTextField(
          controller: nameController,
          hintText: 'John Doe',
          keyboardType: TextInputType.name,
          onChanged: (value) => onFieldChanged(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            if (value.length < 3) {
              return 'Name must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        const FieldLabel(label: 'Institutional Email', required: true),
        const SizedBox(height: 8),
        CustomTextField(
          controller: emailController,
          hintText: 'example@am.amrita.edu',
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        const FieldLabel(label: 'Student ID', required: true),
        const SizedBox(height: 8),
        CustomTextField(
          controller: studentIdController,
          hintText: 'AM.EN.U4CSE21001',
          keyboardType: TextInputType.text,
          readOnly: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your student ID';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        const FieldLabel(label: 'Phone Number', required: true),
        const SizedBox(height: 8),
        CustomTextField(
          controller: phoneController,
          hintText: '+91 98765 43210',
          keyboardType: TextInputType.phone,
          onChanged: (value) => onFieldChanged(),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (value.length != 10) {
              return 'Please enter a valid 10-digit phone number';
            }
            return null;
          },
        ),
      ],
    );
  }
}