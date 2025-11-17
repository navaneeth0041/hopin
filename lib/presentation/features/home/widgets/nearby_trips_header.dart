import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NearbyTripsHeader extends StatelessWidget {
  final bool hasUserLocation;
  final bool isLoadingLocation;

  const NearbyTripsHeader({
    super.key,
    required this.hasUserLocation,
    required this.isLoadingLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Nearby Trips",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (hasUserLocation && !isLoadingLocation) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryYellow.withOpacity(0.4),
                width: 0.5,
              ),
            ),
            child: const Text(
              "2km radius",
              style: TextStyle(
                color: AppColors.primaryYellow,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
