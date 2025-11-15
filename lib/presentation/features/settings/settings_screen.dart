// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/auth_provider.dart';
import 'package:hopin/data/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_menu_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Consumer<UserProfileProvider>(
          builder: (context, profileProvider, child) {
            final profile = profileProvider.userProfile;

            return SingleChildScrollView(
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
                        const Text(
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

                    SettingsHeader(
                      name: profile.name,
                      email: profile.email,
                      phone: profile.phone,
                      profileImage: profile.profileImagePath,
                    ),

                    const SizedBox(height: 32),

                    SettingsMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () {
                        Navigator.pushNamed(context, '/edit-profile');
                      },
                    ),

                    const SizedBox(height: 16),

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
                            title: const Text(
                              'Logout',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            content: const Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Provider.of<UserProfileProvider>(
                                    context,
                                    listen: false,
                                  ).clearProfile();

                                  await Provider.of<AuthProvider>(
                                    context,
                                    listen: false,
                                  ).signOut();

                                  if (context.mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/login',
                                      (route) => false,
                                    );
                                  }
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
            );
          },
        ),
      ),
    );
  }
}
