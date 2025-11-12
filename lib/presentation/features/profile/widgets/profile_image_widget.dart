import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/services/image_cache_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageWidget extends StatelessWidget {
  final File? profileImage;
  final String? existingImageBase64;
  final Function(File?) onImageSelected;
  final int completionPercentage;

  const ProfileImageWidget({
    super.key,
    required this.profileImage,
    required this.existingImageBase64,
    required this.onImageSelected,
    required this.completionPercentage,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (image != null) {
      onImageSelected(File(image.path));
    }
  }

  void _showImagePickerBottomSheet(BuildContext context) {
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
              context: context,
              icon: Icons.camera_alt_outlined,
              title: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
            _buildImageOption(
              context: context,
              icon: Icons.photo_library_outlined,
              title: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            if (profileImage != null || existingImageBase64 != null) ...[
              const SizedBox(height: 12),
              _buildImageOption(
                context: context,
                icon: Icons.delete_outline,
                title: 'Remove Photo',
                onTap: () {
                  Navigator.pop(context);
                  onImageSelected(null);
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
    required BuildContext context,
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

  Widget _buildProfileImage() {
    final imageCache = ImageCacheService();
    
    if (profileImage != null) {
      return Image.file(
        profileImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    } else if (existingImageBase64 != null) {
      final image = imageCache.base64ToImage(existingImageBase64);
      if (image != null) {
        return SizedBox(
          width: 120,
          height: 120,
          child: image,
        );
      }
    }
    
    return const Icon(
      Icons.person,
      size: 60,
      color: AppColors.textSecondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => _showImagePickerBottomSheet(context),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2C2C2E),
                    border: Border.all(
                      color: AppColors.primaryYellow.withOpacity(0.3),
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
                  onTap: () => _showImagePickerBottomSheet(context),
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
              color: AppColors.primaryYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryYellow.withOpacity(0.3),
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
                  'Profile $completionPercentage% Complete',
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
    );
  }
}