import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                      const SizedBox(width: 44),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2C2C2E),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  ProfileHeader(
                    name: profile.name,
                    email: profile.email,
                    profileImagePath: profile.profileImagePath,
                    profileImageBase64: profile.profileImageBase64,
                    completionPercentage: profileProvider.completionPercentage,
                    onEditTap: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                  ),

                  const SizedBox(height: 32),

                  // ProfileMenuItem(
                  //   icon: Icons.history,
                  //   title: 'Trip History',
                  //   subtitle: 'View past rides and payments',
                  //   onTap: () {
                  //     Navigator.pushNamed(context, '/trip-history');
                  //   },
                  // ),

                  const SizedBox(height: 16),

                  ProfileMenuItem(
                    icon: Icons.emergency_outlined,
                    title: 'Emergency Contact',
                    subtitle: 'Setup SOS and emergency contacts',
                    onTap: () {
                      Navigator.pushNamed(context, '/emergency-contact');
                    },
                  ),

                  const SizedBox(height: 16),

                  ProfileMenuItem(
                    icon: Icons.local_taxi_outlined,
                    title: 'Driver Directory',
                    subtitle: 'View verified auto/taxi drivers',
                    onTap: () {
                      Navigator.pushNamed(context, '/driver-directory');
                    },
                  ),

                  const SizedBox(height: 16),

                  ProfileMenuItem(
                    icon: Icons.report_problem_outlined,
                    iconColor: Colors.yellow,
                    title: 'Report & Support',
                    subtitle: 'Report issues or get help',
                    onTap: () {
                      Navigator.pushNamed(context, '/report-support');
                    },
                  ),

                  const SizedBox(height: 16),

                  ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'Account and app preferences',
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
