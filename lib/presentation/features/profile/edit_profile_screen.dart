import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/user_profile_provider.dart';
import 'package:hopin/presentation/common_widgets/custom_button.dart';
import 'package:hopin/presentation/features/profile/widgets/profile_image_widget.dart';
import 'package:hopin/presentation/features/profile/widgets/basic_info_section.dart';
import 'package:hopin/presentation/features/profile/widgets/additional_details_section.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _hostelController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _hometownController = TextEditingController();
  final _bioController = TextEditingController();

  // State variables
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  File? _profileImage;
  String? _existingImageBase64;
  bool _imageChanged = false;
  bool _imageRemoved = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final profile = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    ).userProfile;

    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _studentIdController.text = profile.studentId;
    _phoneController.text = profile.phone;
    _departmentController.text = profile.department ?? '';
    _yearController.text = profile.year ?? '';
    _hostelController.text = profile.hostel ?? '';
    _roomNumberController.text = profile.roomNumber ?? '';
    _hometownController.text = profile.hometown ?? '';
    _bioController.text = profile.bio ?? '';
    _selectedGender = profile.gender;

    if (profile.dateOfBirth != null) {
      try {
        _selectedDateOfBirth = DateFormat('dd/MM/yyyy').parse(profile.dateOfBirth!);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    // Load base64 image
    if (profile.profileImageBase64 != null && profile.profileImageBase64!.isNotEmpty) {
      _existingImageBase64 = profile.profileImageBase64;
    } else if (profile.profileImagePath != null && profile.profileImagePath!.isNotEmpty) {
      _profileImage = File(profile.profileImagePath!);
    }
  }

  void _handleImageSelection(File? image) {
    setState(() {
      if (image == null) {
        // Remove image
        _profileImage = null;
        _existingImageBase64 = null;
        _imageChanged = true;
        _imageRemoved = true;
      } else {
        // New image selected
        _profileImage = image;
        _imageChanged = true;
        _imageRemoved = false;
        _existingImageBase64 = null;
      }
    });
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileProvider = Provider.of<UserProfileProvider>(
        context,
        listen: false,
      );

      _showLoadingDialog();

      try {
        Map<String, dynamic> updates = {
          'fullName': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'studentId': _studentIdController.text.trim(),
          'gender': _selectedGender,
          'dateOfBirth': _selectedDateOfBirth != null
              ? DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!)
              : null,
          'department': _departmentController.text.trim().isNotEmpty
              ? _departmentController.text.trim()
              : null,
          'year': _yearController.text.trim().isNotEmpty
              ? _yearController.text.trim()
              : null,
          'hostel': _hostelController.text.trim().isNotEmpty
              ? _hostelController.text.trim()
              : null,
          'roomNumber': _roomNumberController.text.trim().isNotEmpty
              ? _roomNumberController.text.trim()
              : null,
          'hometown': _hometownController.text.trim().isNotEmpty
              ? _hometownController.text.trim()
              : null,
          'bio': _bioController.text.trim().isNotEmpty
              ? _bioController.text.trim()
              : null,
        };

        if (_imageRemoved) {
          updates['removeProfileImage'] = true;
        }

        final success = await profileProvider.updateProfile(
          updates,
          profileImage: (_imageChanged && _profileImage != null) ? _profileImage : null,
        );

        if (!mounted) return;

        Navigator.pop(context); // Close loading dialog

        if (success) {
          _showSuccessDialog(profileProvider.completionPercentage);
        } else {
          _showErrorSnackbar(profileProvider.errorMessage ?? 'Failed to update profile');
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        _showErrorSnackbar('Failed to update profile: $e');
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    height: 64,
                    width: 64,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _imageChanged && _profileImage != null
                          ? Icons.cloud_upload_rounded
                          : Icons.sync_rounded,
                      color: AppColors.primaryYellow,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _imageChanged && _profileImage != null
                    ? 'Uploading image...'
                    : 'Updating profile...',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please wait a moment',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(int completion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.accentGreen,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Profile Updated!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your profile is $completion% complete.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentRed,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _hostelController.dispose();
    _roomNumberController.dispose();
    _hometownController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        final completion = profileProvider.completionPercentage;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                        child: Text(
                          'Edit Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileImageWidget(
                            profileImage: _profileImage,
                            existingImageBase64: _existingImageBase64,
                            onImageSelected: _handleImageSelection,
                            completionPercentage: completion,
                          ),
                          const SizedBox(height: 32),
                          
                          BasicInfoSection(
                            nameController: _nameController,
                            emailController: _emailController,
                            studentIdController: _studentIdController,
                            phoneController: _phoneController,
                            onFieldChanged: () => setState(() {}),
                          ),
                          const SizedBox(height: 32),
                          
                          AdditionalDetailsSection(
                            selectedGender: _selectedGender,
                            selectedDateOfBirth: _selectedDateOfBirth,
                            departmentController: _departmentController,
                            yearController: _yearController,
                            hostelController: _hostelController,
                            roomNumberController: _roomNumberController,
                            hometownController: _hometownController,
                            bioController: _bioController,
                            onGenderChanged: (value) => setState(() => _selectedGender = value),
                            onDateOfBirthChanged: (value) => setState(() => _selectedDateOfBirth = value),
                            onYearChanged: (value) => setState(() => _yearController.text = value ?? ''),
                          ),
                          const SizedBox(height: 32),
                          
                          // Info Banner
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.accentBlue.withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.accentBlue,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Fill optional fields to complete your profile and improve your experience',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          CustomButton(
                            text: 'Save Changes',
                            onPressed: _saveProfile,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}