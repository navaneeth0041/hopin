import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/report_provider.dart';
import '../../common_widgets/custom_buttons.dart';
import '../../common_widgets/custom_text_field.dart';
import 'widgets/report_category_card.dart';
import 'widgets/tab_selector.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/contact_method_card.dart';
import 'widgets/faq_item.dart';
import 'widgets/emergency_help_banner.dart';

class ReportSupportScreen extends StatefulWidget {
  const ReportSupportScreen({super.key});

  @override
  State<ReportSupportScreen> createState() => _ReportSupportScreenState();
}

class _ReportSupportScreenState extends State<ReportSupportScreen> {
  String _selectedTab = 'report';
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  final List<_ReportCategory> _reportCategories = [
    _ReportCategory(
      icon: Icons.dangerous_outlined,
      title: 'Safety Concern',
      subtitle: 'Report unsafe behavior or incidents',
    ),
    _ReportCategory(
      icon: Icons.person_off_outlined,
      title: 'Driver Issue',
      subtitle: 'Report driver misconduct or problems',
    ),
    _ReportCategory(
      icon: Icons.directions_car_outlined,
      title: 'Vehicle Problem',
      subtitle: 'Report vehicle condition issues',
    ),
    _ReportCategory(
      icon: Icons.payment_outlined,
      title: 'Payment Dispute',
      subtitle: 'Report billing or payment issues',
    ),
    _ReportCategory(
      icon: Icons.route_outlined,
      title: 'Route Problem',
      subtitle: 'Report incorrect routes or detours',
    ),
    _ReportCategory(
      icon: Icons.report_outlined,
      title: 'Other',
      subtitle: 'Report other concerns',
    ),
  ];

  final List<_FAQ> _faqs = [
    _FAQ(
      question: 'How do I report a safety issue during a trip?',
      answer:
          'You can report safety issues in real-time using the SOS button on your trip screen, or after the trip through this Report & Support page.',
    ),
    _FAQ(
      question: 'What happens after I submit a report?',
      answer:
          'Our safety team reviews all reports within 24 hours. You\'ll receive updates via email and in-app notifications.',
    ),
    _FAQ(
      question: 'How can I contact support?',
      answer:
          'You can reach us through this support form, email us at support@hopin.com, or call our helpline at 1800-XXX-XXXX.',
    ),
    _FAQ(
      question: 'Can I cancel or modify a submitted report?',
      answer:
          'Yes, you can view and update your reports in the "My Reports" section before they are reviewed.',
    ),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onTabChanged(String tab) {
    setState(() {
      _selectedTab = tab;
      _selectedCategory = null;
      _descriptionController.clear();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
    });
  }

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
                  const Expanded(
                    child: Text(
                      'Report & Support',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            TabSelector(
              selectedTab: _selectedTab,
              onTabChanged: _onTabChanged,
            ),
            Expanded(
              child: _selectedTab == 'report'
                  ? _buildReportTab()
                  : _buildSupportTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What would you like to report?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your safety is our priority. All reports are confidential.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ..._reportCategories.map((category) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ReportCategoryCard(
                  icon: category.icon,
                  title: category.title,
                  subtitle: category.subtitle,
                  isSelected: _selectedCategory == category.title,
                  onTap: () => _onCategorySelected(category.title),
                ),
              )),
          if (_selectedCategory != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Describe the issue',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _descriptionController,
              hintText: 'Please provide detailed information...',
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            _isSubmitting
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryYellow,
                    ),
                  )
                : PrimaryButton(
                    label: 'Submit Report',
                    onPressed: _submitReport,
                    icon: Icons.send_outlined,
                  ),
          ],
          const SizedBox(height: 32),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSupportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactSupport(),
          const SizedBox(height: 32),
          _buildFAQSection(),
          const SizedBox(height: 32),
          EmergencyHelpBanner(
            onEmergencyContactsTap: () {
              Navigator.pushNamed(context, '/emergency-contact');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.history,
                label: 'My Reports',
                onTap: () {
                  Navigator.pushNamed(context, '/my-reports');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.call,
                label: 'Emergency',
                onTap: () {
                  Navigator.pushNamed(context, '/emergency-contact');
                },
                isEmergency: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSupport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Support',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Our team is here to help you 24/7',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _emailController,
          hintText: 'Your email address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _descriptionController,
          hintText: 'How can we help you?',
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 20),
        _isSubmitting
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryYellow,
                ),
              )
            : PrimaryButton(
                label: 'Send Message',
                onPressed: _submitSupport,
                icon: Icons.send_outlined,
              ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(
              child: ContactMethodCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: 'support@hopin.com',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ContactMethodCard(
                icon: Icons.phone_outlined,
                title: 'Phone',
                value: '1800-XXX-XXXX',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ..._faqs.map((faq) => FAQItemWidget(
              question: faq.question,
              answer: faq.answer,
            )),
      ],
    );
  }

  void _submitReport() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a description'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final result = await reportProvider.submitReport(
      category: _selectedCategory!,
      description: _descriptionController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success'] == true) {
      _showSuccessDialog(
        title: 'Report Submitted',
        message:
            'Your report has been submitted successfully. Our team will review it within 24 hours.',
        onClose: () {
          setState(() {
            _selectedCategory = null;
            _descriptionController.clear();
          });
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to submit report'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  void _submitSupport() async {
    if (_emailController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final result = await reportProvider.submitSupportTicket(
      email: _emailController.text.trim(),
      description: _descriptionController.text.trim(),
      subject: 'General Support',
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success'] == true) {
      _showSuccessDialog(
        title: 'Support Ticket Created',
        message:
            'Your support ticket has been created successfully. We\'ll get back to you within 24 hours.',
        onClose: () {
          _emailController.clear();
          _descriptionController.clear();
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to create support ticket'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  void _showSuccessDialog({
    required String title,
    required String message,
    required VoidCallback onClose,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.accentGreen,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onClose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCategory {
  final IconData icon;
  final String title;
  final String subtitle;

  _ReportCategory({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _FAQ {
  final String question;
  final String answer;

  _FAQ({
    required this.question,
    required this.answer,
  });
}