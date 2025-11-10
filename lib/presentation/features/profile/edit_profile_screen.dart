import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/user_profile_provider.dart';
import 'package:hopin/presentation/common_widgets/custom_button.dart';
import 'package:hopin/presentation/common_widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

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

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  File? _profileImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();
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
        _selectedDateOfBirth = DateFormat(
          'dd/MM/yyyy',
        ).parse(profile.dateOfBirth!);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    if (profile.profileImageUrl != null &&
        profile.profileImageUrl!.isNotEmpty) {
      _existingImageUrl = profile.profileImageUrl;
    } else if (profile.profileImagePath != null &&
        profile.profileImagePath!.isNotEmpty) {
      _profileImage = File(profile.profileImagePath!);
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
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

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildImageOption(
              icon: Icons.camera_alt_outlined,
              title: 'Take Photo',
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (image != null) {
                  setState(() {
                    _profileImage = File(image.path);
                    _imageChanged = true;
                    _imageRemoved = false;
                    _existingImageUrl = null;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            _buildImageOption(
              icon: Icons.photo_library_outlined,
              title: 'Choose from Gallery',
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (image != null) {
                  setState(() {
                    _profileImage = File(image.path);
                    _imageChanged = true;
                    _imageRemoved = false;
                    _existingImageUrl = null;
                  });
                }
              },
            ),
            if (_profileImage != null || _existingImageUrl != null) ...[
              const SizedBox(height: 12),
              _buildImageOption(
                icon: Icons.delete_outline,
                title: 'Remove Photo',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                    _existingImageUrl = null;
                    _imageChanged = true;
                    _imageRemoved = true;
                  });
                },
                isDestructive: true,
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? AppColors.accentRed
                  : AppColors.textPrimary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? AppColors.accentRed
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileProvider = Provider.of<UserProfileProvider>(
        context,
        listen: false,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
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
                Text(
                  'Please wait a moment',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );

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
          profileImage: (_imageChanged && _profileImage != null)
              ? _profileImage
              : null,
        );

        if (!mounted) return;

        Navigator.pop(context);

        if (success) {
          final completion = profileProvider.completionPercentage;
          // final message = profileProvider.completionMessage;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                profileProvider.errorMessage ?? 'Failed to update profile',
              ),
              backgroundColor: AppColors.accentRed,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Widget _buildFieldLabel(String label, {bool required = true}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          children: required
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.accentRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]
              : [
                  const TextSpan(
                    text: ' (optional)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_profileImage != null) {
      return Image.file(
        _profileImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    } else if (_existingImageUrl != null) {
      return Image.network(
        _existingImageUrl!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primaryYellow,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.person,
            size: 60,
            color: AppColors.textSecondary,
          );
        },
      );
    } else {
      return const Icon(Icons.person, size: 60, color: AppColors.textSecondary);
    }
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

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF2C2C2E),
                                          border: Border.all(
                                            color: AppColors.primaryYellow
                                                .withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: _buildProfileImage(),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryYellow,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.darkBackground,
                                              width: 3,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryYellow.withOpacity(
                                      0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primaryYellow
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_user,
                                        size: 16,
                                        color: AppColors.primaryYellow,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Profile $completion% Complete',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryYellow,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          _buildSectionHeader('Basic Information'),

                          _buildFieldLabel('Full Name'),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'John Doe',
                            keyboardType: TextInputType.name,
                            onChanged: (value) => setState(() {}),
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

                          _buildFieldLabel('Institutional Email'),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _emailController,
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

                          _buildFieldLabel('Student ID'),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _studentIdController,
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

                          _buildFieldLabel('Phone Number'),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _phoneController,
                            hintText: '+91 98765 43210',
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => setState(() {}),
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

                          const SizedBox(height: 32),

                          _buildSectionHeader('Additional Details'),

                          _buildFieldLabel('Gender', required: false),
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
                                value: _selectedGender,
                                hint: const Text(
                                  'Select Gender',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                isExpanded: true,
                                dropdownColor: AppColors.cardBackground,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                items:
                                    [
                                          'Male',
                                          'Female',
                                          'Other',
                                          'Prefer not to say',
                                        ]
                                        .map(
                                          (gender) => DropdownMenuItem(
                                            value: gender,
                                            child: Text(gender),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildFieldLabel('Date of Birth', required: false),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectDateOfBirth,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C2C2E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedDateOfBirth != null
                                        ? DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_selectedDateOfBirth!)
                                        : 'Select Date',
                                    style: TextStyle(
                                      color: _selectedDateOfBirth != null
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

                          _buildFieldLabel('Department', required: false),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _departmentController,
                            hintText: 'Computer Science',
                            keyboardType: TextInputType.text,
                          ),

                          const SizedBox(height: 20),

                          _buildFieldLabel('Year', required: false),
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
                                value: _yearController.text.isEmpty
                                    ? null
                                    : _yearController.text,
                                hint: const Text(
                                  'Select Year',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                isExpanded: true,
                                dropdownColor: AppColors.cardBackground,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                items:
                                    [
                                          '1st Year',
                                          '2nd Year',
                                          '3rd Year',
                                          '4th Year',
                                          '5th Year',
                                        ]
                                        .map(
                                          (year) => DropdownMenuItem(
                                            value: year,
                                            child: Text(year),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _yearController.text = value ?? '';
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildFieldLabel('Hostel', required: false),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _hostelController,
                            hintText: 'Hostel Name',
                            keyboardType: TextInputType.text,
                          ),

                          const SizedBox(height: 20),

                          _buildFieldLabel('Room Number', required: false),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _roomNumberController,
                            hintText: '201',
                            keyboardType: TextInputType.text,
                          ),

                          const SizedBox(height: 20),

                          _buildFieldLabel('Hometown', required: false),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _hometownController,
                            hintText: 'City, State',
                            keyboardType: TextInputType.text,
                          ),

                          const SizedBox(height: 20),

                          _buildFieldLabel('Bio', required: false),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _bioController,
                            hintText: 'Tell us about yourself...',
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                          ),

                          const SizedBox(height: 32),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.accentBlue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.accentBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
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
