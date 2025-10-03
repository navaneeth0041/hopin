import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_menu_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                const SettingsHeader(
                  name: 'Orville Black',
                  email: 'jacquelyn_fitzgerald@icloud.com',
                  phone: '+(555) 123-4567',
                  profileImage: null,
                ),

                const SizedBox(height: 32),

                Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                SettingsMenuItem(
                  icon: Icons.home_outlined,
                  title: 'Add Home',
                  onTap: () {},
                ),

                const SizedBox(height: 12),

                SettingsMenuItem(
                  icon: Icons.work_outline,
                  title: 'Add Work',
                  onTap: () {},
                ),

                const SizedBox(height: 12),

                SettingsMenuItem(
                  icon: Icons.flash_on_outlined,
                  title: 'Shortcuts',
                  onTap: () {},
                ),

                const SizedBox(height: 12),

                SettingsMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Privacy',
                  onTap: () {},
                ),

                const SizedBox(height: 12),

                SettingsMenuItem(
                  icon: Icons.message_outlined,
                  title: 'Communication',
                  onTap: () {},
                ),

                const SizedBox(height: 32),

                Text(
                  'Popular',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                SettingsMenuItem(
                  icon: Icons.verified_user_outlined,
                  title: 'Safety Preferences',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
