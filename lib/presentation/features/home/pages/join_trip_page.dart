import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class JoinTripPage extends StatelessWidget {
  const JoinTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 120.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view, size: 80, color: AppColors.primaryYellow),
            const SizedBox(height: 16),
            Text(
              'Join Trip',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse and join available trips',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
