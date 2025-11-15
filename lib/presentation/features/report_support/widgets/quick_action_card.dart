// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isEmergency;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEmergency
              ? AppColors.accentRed.withOpacity(0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEmergency ? AppColors.accentRed : AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isEmergency ? AppColors.accentRed : AppColors.primaryYellow,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isEmergency ? AppColors.accentRed : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
