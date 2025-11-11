import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/presentation/common_widgets/custom_buttons.dart';

class SeatSelector extends StatelessWidget {
  final int availableSeats;
  final ValueChanged<int> onSeatsChanged;

  const SeatSelector({
    super.key,
    required this.availableSeats,
    required this.onSeatsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_seat,
                  color: AppColors.primaryYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Available Seats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SeatButton(
                icon: Icons.remove,
                onTap: () {
                  if (availableSeats > 1) {
                    onSeatsChanged(availableSeats - 1);
                  }
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$availableSeats',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
              _SeatButton(
                icon: Icons.add,
                onTap: () {
                  if (availableSeats < 6) {
                    onSeatsChanged(availableSeats + 1);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeatButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SeatButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryYellow,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryYellow.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 24),
      ),
    );
  }
}
