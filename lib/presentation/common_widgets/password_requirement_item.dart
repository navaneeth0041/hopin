// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PasswordRequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const PasswordRequirementItem({
    super.key,
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMet 
                  ? AppColors.accentGreen.withOpacity(0.2)
                  : AppColors.cardBackground,
              border: Border.all(
                color: isMet 
                    ? AppColors.accentGreen 
                    : AppColors.textTertiary,
                width: 1.5,
              ),
            ),
            child: isMet
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.accentGreen,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isMet ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}