import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? profileImage;
  final int completionPercentage;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.profileImage,
    required this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: completionPercentage / 100,
                strokeWidth: 6,
                backgroundColor: const Color(0xFF2C2C2E),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryYellow,
                ),
              ),
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2C2C2E),
                image: profileImage != null
                    ? DecorationImage(
                        image: AssetImage(profileImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profileImage == null
                  ? Icon(Icons.person, size: 60, color: AppColors.textSecondary)
                  : null,
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completionPercentage%',
                  style: const TextStyle(
                    fontSize: 14,
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
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          email,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
