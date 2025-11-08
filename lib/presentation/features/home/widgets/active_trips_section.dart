// lib/features/home/widgets/active_trips_section.dart
import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/home/trip_model.dart';
import 'trip_card.dart';

class ActiveTripsSection extends StatelessWidget {
  const ActiveTripsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with real data from provider/bloc
    final activeTrips = [
      TripModel(
        id: '1',
        destination: 'Fort Kochi',
        date: '15 Oct, 2024',
        time: '2:30 PM',
        participants: '2/4',
        fareShare: '₹125',
        status: TripStatus.confirmed,
      ),
      TripModel(
        id: '2',
        destination: 'Ernakulathappan',
        date: '15 Oct, 2024',
        time: '4:00 PM',
        participants: '3/4',
        fareShare: '₹95',
        status: TripStatus.waiting,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Active Trips',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View All Trips')),
                );
              },
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        activeTrips.isEmpty
            ? _EmptyState(
                icon: Icons.directions_car_outlined,
                title: 'No Active Trips',
                subtitle: 'Create or join a trip to get started',
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeTrips.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TripCard(trip: activeTrips[index]),
                ),
              ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}