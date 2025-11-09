import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
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
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUpdateInfo('Last Updated: January 2025'),
                    const SizedBox(height: 24),

                    _buildSection(
                      title: '1. Introduction',
                      content:
                          'HopIn ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
                    ),

                    _buildSection(
                      title: '2. Information We Collect',
                      content: null,
                      subsections: [
                        _buildSubsection(
                          'Personal Information',
                          'We collect information that you provide directly to us, including:\n• Name and college email address\n• Phone number\n• Profile picture (optional)\n• College/institution details',
                        ),
                        _buildSubsection(
                          'Location Data',
                          'We collect real-time location data when you use our ride-sharing features. This helps us match you with riders on similar routes and calculate accurate fares.',
                        ),
                        _buildSubsection(
                          'Trip Information',
                          'We store details about your trips, including routes, timestamps, fare amounts, and co-riders for historical records and payment tracking.',
                        ),
                        _buildSubsection(
                          'Device Information',
                          'We automatically collect certain device information, including device type, operating system, unique device identifiers, and mobile network information.',
                        ),
                      ],
                    ),

                    _buildSection(
                      title: '3. How We Use Your Information',
                      content:
                          'We use the collected information for the following purposes:\n\n• To provide and maintain our ride-sharing service\n• To match you with compatible riders and routes\n• To calculate and process fare splits\n• To communicate important updates about your trips\n• To improve our services and user experience\n• To ensure safety and security of all users\n• To comply with legal obligations',
                    ),

                    _buildSection(
                      title: '4. Information Sharing',
                      content:
                          'We share your information only in the following circumstances:\n\n• With co-riders when you join or create a shared trip\n• With verified auto/taxi drivers for your booked rides\n• With emergency contacts when you activate the SOS feature\n• With college authorities for safety and verification purposes\n• When required by law or legal processes',
                    ),

                    _buildSection(
                      title: '5. Data Security',
                      content:
                          'We implement industry-standard security measures to protect your personal information:\n\n• All data transmissions are encrypted using SSL/TLS\n• Your password is securely hashed and never stored in plain text\n• We use Firebase Authentication for secure user access\n• Payment information is processed through secure gateways\n• Regular security audits and updates',
                    ),

                    _buildSection(
                      title: '6. Your Rights and Choices',
                      content:
                          'You have the following rights regarding your personal data:\n\n• Access and download your personal information\n• Update or correct your profile details\n• Delete your account and associated data\n• Control location sharing permissions\n• Manage notification preferences\n• Opt-out of non-essential communications',
                    ),

                    _buildSection(
                      title: '7. Data Retention',
                      content:
                          'We retain your information for as long as your account is active or as needed to provide services. Trip history and payment records are kept for 2 years for legal and accounting purposes. You may request deletion of your data at any time.',
                    ),

                    _buildSection(
                      title: '8. Children\'s Privacy',
                      content:
                          'HopIn is designed for college students aged 18 and above. We do not knowingly collect information from individuals under 18. If you believe we have collected information from a minor, please contact us immediately.',
                    ),

                    _buildSection(
                      title: '9. Changes to Privacy Policy',
                      content:
                          'We may update this Privacy Policy from time to time. We will notify you of any significant changes through the app or via email. Your continued use of HopIn after changes constitutes acceptance of the updated policy.',
                    ),

                    _buildSection(
                      title: '10. Contact Us',
                      content:
                          'If you have questions or concerns about this Privacy Policy or our data practices, please contact us at:\n\nEmail: support@hopin.app\nAddress: Amrita School of Computing\nAmrita Vishwa Vidyapeetham',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateInfo(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryYellow, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? content,
    List<Widget>? subsections,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          if (subsections != null) ...subsections,
        ],
      ),
    );
  }

  Widget _buildSubsection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
