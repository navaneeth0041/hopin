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
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
            child: Column(
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
                    const SizedBox(width: 44),
                  ],
                ),

                const SizedBox(height: 24),

                const SettingsHeader(
                  name: 'Orville Black',
                  email: 'orville.black@am.amrita.edu',
                  phone: '+91 98765 43210',
                  profileImage: null,
                ),

                const SizedBox(height: 32),

                SettingsMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    Navigator.pushNamed(context, '/notification-settings');
                  },
                ),

                const SizedBox(height: 16),

                SettingsMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location Settings',
                  subtitle: 'Control GPS and location access',
                  onTap: () {
                    Navigator.pushNamed(context, '/location-settings');
                  },
                ),

                const SizedBox(height: 16),

                SettingsMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Privacy & Data',
                  subtitle: 'Manage your privacy settings',
                  onTap: () {
                    Navigator.pushNamed(context, '/privacy');
                  },
                ),

                const SizedBox(height: 16),

                SettingsMenuItem(
                  icon: Icons.block_outlined,
                  title: 'Blocked Users',
                  subtitle: 'View and manage blocked contacts',
                  onTap: () {
                    Navigator.pushNamed(context, '/blocked-users');
                  },
                ),

                const SizedBox(height: 16),

                SettingsMenuItem(
                  icon: Icons.password_outlined,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),

                const SizedBox(height: 16),

                SettingsMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & FAQ',
                  subtitle: 'Get help and find answers',
                  onTap: () {
                    Navigator.pushNamed(context, '/help');
                  },
                ),

                const SizedBox(height: 16),

                SettingsMenuItem(
                  icon: Icons.info_outline,
                  title: 'About HopIn',
                  subtitle: 'App version and information',
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                ),

                const SizedBox(height: 32),

                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF2C2C2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Logout',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red[400],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
