import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class EmergencyHelpBanner extends StatelessWidget {
  final VoidCallback onEmergencyContactsTap;

  const EmergencyHelpBanner({
    super.key,
    required this.onEmergencyContactsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentRed.withOpacity(0.2),
            AppColors.accentRed.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentRed.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.emergency, color: AppColors.accentRed, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Need Immediate Help?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'If you\'re in an emergency situation, contact authorities immediately or use our SOS feature.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEmergencyContactsTap,
              icon: const Icon(Icons.call, size: 20),
              label: const Text('Emergency Contacts'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}