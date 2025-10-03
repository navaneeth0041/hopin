import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_action_card.dart';
import '../widgets/profile_menu_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.share_outlined,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Text(
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
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                      icon: Icon(
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

              const ProfileHeader(
                name: 'Laaal Singh',
                email: 'laal_jodhil@hotmale.com',
                profileImage: null,
                completionPercentage: 76,
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: ProfileActionCard(
                      icon: Icons.help_outline,
                      title: 'Help',
                      subtitle: 'Help is Here.',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ProfileActionCard(
                      icon: Icons.wallet_outlined,
                      title: 'Wallet',
                      subtitle: 'Easy Pay',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ProfileActionCard(
                      icon: Icons.assignment_outlined,
                      title: 'Activity',
                      subtitle: 'Activity Feed',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ProfileActionCard(
                      icon: Icons.mail_outline,
                      title: 'Message',
                      subtitle: 'Chat Now',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              ProfileMenuItem(
                icon: Icons.bookmark_border,
                title: 'Save Groups',
                onTap: () {},
              ),

              const SizedBox(height: 16),

              ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Setting',
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
