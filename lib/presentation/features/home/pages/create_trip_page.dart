import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CreateTripPage extends StatelessWidget {
  const CreateTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle, size: 80, color: AppColors.primaryYellow),
          const SizedBox(height: 16),
          Text(
            'Create Trip',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new trip and share it',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
