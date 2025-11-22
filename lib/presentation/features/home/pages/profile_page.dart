import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/user_profile_provider.dart';
import 'package:hopin/data/providers/trip_payment_provider.dart';
import 'package:hopin/presentation/features/payments/screens/payment_history_screen.dart';
import 'package:hopin/presentation/features/payments/screens/unpaid_trips_screen.dart';
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

                  _buildPaymentsSection(context),

                  const SizedBox(height: 16),

                  // ProfileMenuItem(
                  //   icon: Icons.history,
                  //   title: 'Trip History',
                  //   subtitle: 'View past rides and payments',
                  //   onTap: () {
                  //     Navigator.pushNamed(context, '/trip-history');
                  //   },
                  // ),

                  // const SizedBox(height: 16),

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

  Widget _buildPaymentsSection(BuildContext context) {
    return Consumer<TripPaymentProvider>(
      builder: (context, paymentProvider, child) {
        final unpaidCount = paymentProvider.unpaidTripDetails.length;
        final hasUnpaid = unpaidCount > 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileMenuItem(
              icon: Icons.receipt_long,
              title: 'Payment History',
              subtitle: 'View all payment records',
              iconColor: AppColors.primaryYellow,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentHistoryScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            Stack(
              children: [
                ProfileMenuItem(
                  icon: Icons.payment,
                  title: 'Pending Payments',
                  subtitle: hasUnpaid
                      ? '$unpaidCount ${unpaidCount == 1 ? 'payment' : 'payments'} pending'
                      : 'No pending payments',
                  iconColor: hasUnpaid
                      ? AppColors.accentRed
                      : AppColors.accentGreen,
                  trailing: hasUnpaid
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unpaidCount',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.check_circle,
                          color: AppColors.accentGreen,
                          size: 20,
                        ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UnpaidTripsScreen(),
                      ),
                    );
                  },
                ),
                if (hasUnpaid)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}