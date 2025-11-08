import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SizedBox(
        //   width: double.infinity,
        //   height: 56,
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: AppColors.primaryYellow,
        //       elevation: 8,
        //       shadowColor: AppColors.primaryYellow.withOpacity(0.4),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(16),
        //       ),
        //     ),
        //     onPressed: () {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text('Navigate to Create Trip')),
        //       );
        //     },
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Icon(
        //           Icons.add_circle_outline,
        //           color: Colors.black,
        //           size: 22,
        //         ),
        //         const SizedBox(width: 8),
        //         Text(
        //           'Create Trip',
        //           style: TextStyle(
        //             fontSize: 16,
        //             fontWeight: FontWeight.bold,
        //             color: Colors.black,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.directions_car_outlined,
                label: 'Find Rides',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigate to Find Rides')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.emergency_outlined,
                label: 'Emergency SOS',
                backgroundColor: AppColors.accentRed,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Emergency SOS Activated')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.cardBackground;
    final textColor = backgroundColor == AppColors.accentRed
        ? AppColors.textPrimary
        : AppColors.textPrimary;
    final iconColor = backgroundColor == AppColors.accentRed
        ? Colors.white
        : AppColors.primaryYellow;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}