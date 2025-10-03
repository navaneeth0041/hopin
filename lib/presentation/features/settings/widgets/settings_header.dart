import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class SettingsHeader extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String? profileImage;

  const SettingsHeader({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
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
                ? Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_outlined,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}