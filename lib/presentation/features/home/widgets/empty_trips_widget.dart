import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EmptyTripsWidget extends StatelessWidget {
  final bool isLoadingLocation;
  final bool hasUserLocation;

  const EmptyTripsWidget({
    super.key,
    required this.isLoadingLocation,
    required this.hasUserLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Removed the circular icon container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    isLoadingLocation
                        ? Colors.blue.withOpacity(0.2)
                        : AppColors.primaryYellow.withOpacity(0.2),
                    isLoadingLocation
                        ? Colors.blue.withOpacity(0.1)
                        : AppColors.primaryYellow.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: isLoadingLocation
                      ? Colors.blue.withOpacity(0.3)
                      : AppColors.primaryYellow.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                isLoadingLocation
                    ? Icons.location_searching
                    : hasUserLocation
                    ? Icons.radar
                    : Icons.search,
                color: isLoadingLocation
                    ? Colors.blue.withOpacity(0.8)
                    : hasUserLocation
                    ? AppColors.primaryYellow.withOpacity(0.8)
                    : Colors.white.withOpacity(0.6),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isLoadingLocation
                  ? 'Finding trips near you...'
                  : hasUserLocation
                  ? 'No trips found nearby'
                  : 'Loading available trips...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isLoadingLocation
                  ? 'Please wait while we locate you'
                  : hasUserLocation
                  ? 'No active trips within 2km radius of your location'
                  : 'Searching for available rides...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),

          ],
        ),
      ),
    );
  }
}
