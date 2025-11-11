import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';

class TripSuccessDialog extends StatelessWidget {
  final String currentLocation;
  final String destination;
  final int availableSeats;

  const TripSuccessDialog({
    super.key,
    required this.currentLocation,
    required this.destination,
    required this.availableSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryYellow.withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 46,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Trip Posted Successfully!",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Your ride is now live and visible to others",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            currentLocation,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '•••',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_right_alt_rounded,
                              color: AppColors.primaryYellow,
                              size: 20,
                            ),
                          ],
                        ),

                        Expanded(
                          child: Text(
                            destination,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _tripDetail(
                          icon: Icons.calendar_today_rounded,
                          label: "8 Nov 2025",
                        ),
                        _tripDetail(
                          icon: Icons.access_time_rounded,
                          label: "4:30 PM",
                        ),
                        _tripDetail(
                          icon: Icons.event_seat_rounded,
                          label: "$availableSeats seats",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tripDetail({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryYellow, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
