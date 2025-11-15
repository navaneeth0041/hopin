// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/trip.dart';

class TripDetailBottomSheet extends StatelessWidget {
  final Trip trip;

  const TripDetailBottomSheet({super.key, required this.trip});

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:$minute $period';

    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    return '$date at $time';
  }

  Color _getStatusColor() {
    switch (trip.status) {
      case TripStatus.active:
        return AppColors.accentGreen;
      case TripStatus.full:
        return AppColors.primaryYellow;
      case TripStatus.completed:
        return Colors.blue;
      case TripStatus.cancelled:
        return AppColors.accentRed;
    }
  }

  String _getStatusText() {
    switch (trip.status) {
      case TripStatus.active:
        return 'Active';
      case TripStatus.full:
        return 'Full';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final passengers = [
      {'name': 'John Doe', 'phone': '+91 98765 43210'},
      {'name': 'Jane Smith', 'phone': '+91 87654 32109'},
      {'name': 'Mike Johnson', 'phone': '+91 76543 21098'},
    ];

    final filledSeats = trip.totalSeats - trip.availableSeats;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: const Text(
                  'Trip Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getStatusColor().withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                trip.status == TripStatus.active ||
                                        trip.status == TripStatus.full
                                    ? Icons.directions_car
                                    : trip.status == TripStatus.completed
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _getStatusColor(),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getStatusText(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'Route Information',
                        icon: Icons.route,
                        children: [
                          _buildDetailRow(
                            icon: Icons.my_location,
                            label: 'From',
                            value: trip.currentLocation,
                          ),
                          _buildDetailRow(
                            icon: Icons.location_on,
                            label: 'To',
                            value: trip.destination,
                          ),
                          _buildDetailRow(
                            icon: Icons.schedule,
                            label: 'Departure',
                            value: _formatDateTime(trip.departureTime),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'Seats & Capacity',
                        icon: Icons.event_seat,
                        children: [
                          _buildDetailRow(
                            icon: Icons.airline_seat_recline_normal,
                            label: 'Total Seats',
                            value: '${trip.totalSeats} seats',
                          ),
                          _buildDetailRow(
                            icon: Icons.people,
                            label: 'Filled Seats',
                            value: '$filledSeats seats',
                            valueColor: filledSeats > 0
                                ? AppColors.accentGreen
                                : null,
                          ),
                          _buildDetailRow(
                            icon: Icons.event_seat_outlined,
                            label: 'Available Seats',
                            value: '${trip.availableSeats} seats',
                            valueColor: trip.availableSeats > 0
                                ? AppColors.primaryYellow
                                : AppColors.accentRed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (filledSeats > 0)
                        _buildSectionCard(
                          title: 'Passengers ($filledSeats)',
                          icon: Icons.people_alt,
                          children: [
                            ...List.generate(
                              filledSeats,
                              (index) => _buildPassengerCard(
                                name:
                                    passengers[index %
                                        passengers.length]['name']!,
                                phone:
                                    passengers[index %
                                        passengers.length]['phone']!,
                                isLast: index == filledSeats - 1,
                              ),
                            ),
                          ],
                        ),

                      if (filledSeats > 0) const SizedBox(height: 16),

                      if (trip.note != null && trip.note!.isNotEmpty)
                        _buildSectionCard(
                          title: 'Additional Notes',
                          icon: Icons.note,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.darkBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                trip.note!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
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
                child: Icon(icon, color: AppColors.primaryYellow, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerCard({
    required String name,
    required String phone,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: AppColors.primaryYellow, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppColors.accentGreen, size: 20),
        ],
      ),
    );
  }
}
