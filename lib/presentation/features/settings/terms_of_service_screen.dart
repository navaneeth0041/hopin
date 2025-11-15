// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                    'Terms of Service',
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
                    _buildUpdateInfo('Effective Date: January 2025'),
                    const SizedBox(height: 24),

                    _buildSection(
                      title: '1. Acceptance of Terms',
                      content:
                          'By accessing and using HopIn, you accept and agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service. These terms apply to all users, including students, drivers, and administrators.',
                    ),

                    _buildSection(
                      title: '2. Eligibility',
                      content:
                          'To use HopIn, you must:\n\n• Be a currently enrolled college student\n• Be at least 18 years of age\n• Possess a valid college email address\n• Have the legal capacity to enter into this agreement\n• Comply with all local transportation and safety laws',
                    ),

                    _buildSection(
                      title: '3. User Accounts',
                      content: null,
                      subsections: [
                        _buildSubsection(
                          'Account Registration',
                          'You must provide accurate and complete information during registration. You are responsible for maintaining the confidentiality of your account credentials and for all activities under your account.',
                        ),
                        _buildSubsection(
                          'Account Security',
                          'You must notify us immediately of any unauthorized use of your account. We reserve the right to suspend or terminate accounts that violate these terms or engage in suspicious activity.',
                        ),
                        _buildSubsection(
                          'Verification',
                          'All users must verify their college email address. We may request additional verification documents to ensure the safety of our community.',
                        ),
                      ],
                    ),

                    _buildSection(
                      title: '4. Service Usage',
                      content: null,
                      subsections: [
                        _buildSubsection(
                          'Ride Sharing',
                          'HopIn facilitates connections between students traveling similar routes. We are not a transportation provider but a platform connecting riders. Users are responsible for their own safety and transportation arrangements.',
                        ),
                        _buildSubsection(
                          'Fare Calculation',
                          'Fare amounts are calculated automatically based on distance and number of riders. Users agree to pay their share as calculated by the app. Disputes should be resolved between riders or reported through our support system.',
                        ),
                        _buildSubsection(
                          'Location Services',
                          'You must enable GPS and location services to use ride-matching features. Location data is used solely for route matching and safety purposes as outlined in our Privacy Policy.',
                        ),
                      ],
                    ),

                    _buildSection(
                      title: '5. User Conduct',
                      content:
                          'You agree NOT to:\n\n• Provide false or misleading information\n• Harass, threaten, or intimidate other users\n• Use the service for illegal activities\n• Share your account with others\n• Attempt to manipulate fare calculations\n• Impersonate other users or drivers\n• Upload inappropriate or offensive content\n• Spam or solicit other users\n• Reverse engineer or compromise the app',
                    ),

                    _buildSection(
                      title: '6. Payment Terms',
                      content:
                          'All payments are processed through secure third-party payment gateways. You agree to:\n\n• Pay your fare share promptly after each trip\n• Provide valid payment information\n• Accept fare calculations made by the app\n• Not dispute legitimate charges\n\nRefunds are handled on a case-by-case basis for cancelled trips or technical errors.',
                    ),

                    _buildSection(
                      title: '7. Safety and Emergency',
                      content:
                          'Your safety is our priority. HopIn provides:\n\n• Verified driver directory\n• Real-time location sharing\n• SOS emergency alert features\n• Trip history and rider details\n• Reporting and blocking capabilities\n\nHowever, you acknowledge that shared transportation involves inherent risks and you participate at your own discretion.',
                    ),

                    _buildSection(
                      title: '8. Intellectual Property',
                      content:
                          'All content, features, and functionality of HopIn, including but not limited to text, graphics, logos, and software, are owned by HopIn and protected by copyright and trademark laws. You may not copy, modify, or distribute any part of the app without permission.',
                    ),

                    _buildSection(
                      title: '9. Limitation of Liability',
                      content:
                          'HopIn is a platform connecting students and does not provide transportation services. We are not liable for:\n\n• Acts or omissions of drivers or riders\n• Accidents, injuries, or property damage\n• Disputes between users\n• Technical failures or service interruptions\n• Loss of data or unauthorized access\n\nOur liability is limited to the maximum extent permitted by law.',
                    ),

                    _buildSection(
                      title: '10. Termination',
                      content:
                          'We reserve the right to suspend or terminate your access to HopIn at any time for:\n\n• Violation of these terms\n• Fraudulent or illegal activity\n• Harmful behavior toward other users\n• Prolonged inactivity\n\nYou may also delete your account at any time through the app settings.',
                    ),

                    _buildSection(
                      title: '11. Changes to Terms',
                      content:
                          'We may modify these Terms of Service at any time. Significant changes will be communicated through the app or via email. Your continued use after changes constitutes acceptance of the new terms.',
                    ),

                    _buildSection(
                      title: '12. Governing Law',
                      content:
                          'These terms are governed by the laws of India. Any disputes will be resolved in the courts of Kerala. For student-related matters, college policies and guidelines also apply.',
                    ),

                    _buildSection(
                      title: '13. Contact Information',
                      content:
                          'For questions, concerns, or support regarding these Terms of Service:\n\nEmail: support@hopin.app\nAddress: Amrita School of Computing\nAmrita Vishwa Vidyapeetham\n\nFor emergencies, please use the in-app SOS feature or contact local authorities.',
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryYellow.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.primaryYellow,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'By using HopIn, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
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
