import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
  
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryYellow.withValues(alpha: 0.9),
                    AppColors.primaryYellow.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.primaryYellow.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.pushNamed(context, '/create-trip');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.black,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Create Trip',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),

        // Secondary Action Buttons
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.directions_car_outlined,
                label: 'Find Rides',
                onPressed: () {
                  Navigator.pushNamed(context, '/join-trip');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionButton(
                icon: Icons.emergency_outlined,
                label: 'Emergency SOS',
                isEmergency: true,
                onPressed: () async {
                  // Show confirmation dialog first
                  final confirmed = await _showSOSConfirmation(context);
                  if (confirmed == true && context.mounted) {
                    // Navigate to emergency contact screen to set up or trigger SOS
                    Navigator.pushNamed(context, '/emergency-contact');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<bool?> _showSOSConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.emergency_outlined,
                color: AppColors.accentRed,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Emergency SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'This will take you to set up or access your emergency contacts for SOS functionality.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isEmergency;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isEmergency
                  ? [
                      AppColors.accentRed.withValues(alpha: 0.15),
                      AppColors.accentRed.withValues(alpha: 0.08),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEmergency
                  ? AppColors.accentRed.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPressed,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isEmergency ? AppColors.accentRed : AppColors.primaryYellow,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isEmergency ? AppColors.accentRed : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
