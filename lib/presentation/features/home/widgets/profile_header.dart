// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/services/image_cache_service.dart';
import 'dart:io';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? profileImagePath;
  final String? profileImageBase64;
  final int completionPercentage;
  final VoidCallback? onEditTap;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.profileImagePath,
    this.profileImageBase64,
    required this.completionPercentage,
    this.onEditTap,
  });

  Widget _buildProfileImage() {
    final imageCache = ImageCacheService();

    if (profileImageBase64 != null && profileImageBase64!.isNotEmpty) {
      try {
        final image = imageCache.base64ToImage(profileImageBase64);
        if (image != null) {
          return ClipOval(
            child: SizedBox(width: 110, height: 110, child: image),
          );
        }
      } catch (e) {
        // Silently handle base64 image display errors
      }
    }

    if (profileImagePath != null && profileImagePath!.isNotEmpty) {
      try {
        final file = File(profileImagePath!);
        if (file.existsSync()) {
          return ClipOval(
            child: Image.file(
              file,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            ),
          );
        }
      } catch (e) {
        // Silently handle local image display errors
      }
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return const Icon(Icons.person, size: 55, color: AppColors.textSecondary);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CircularProgressIndicator(
                value: completionPercentage / 100,
                strokeWidth: 4,
                backgroundColor: const Color(0xFF2C2C2E),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryYellow,
                ),
              ),
            ),

            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2C2C2E),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildProfileImage(),
            ),

            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$completionPercentage%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          email,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),

        if (completionPercentage < 100) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.accentBlue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Complete your profile',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.accentBlue,
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 16, color: AppColors.accentGreen),
                SizedBox(width: 8),
                Text(
                  'Profile Complete',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
