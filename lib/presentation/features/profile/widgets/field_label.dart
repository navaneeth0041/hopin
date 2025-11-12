import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const FieldLabel({
    super.key,
    required this.label,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          children: required
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.accentRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]
              : [
                  const TextSpan(
                    text: ' (optional)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}