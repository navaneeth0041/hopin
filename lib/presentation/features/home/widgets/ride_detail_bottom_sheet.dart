import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/home/ride_model.dart';

class RideDetailBottomSheet extends StatelessWidget {
  final RideModel ride;

  const RideDetailBottomSheet({super.key, required this.ride});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  'Ride Details',
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
                      // Driver Info Card
                      _buildSectionCard(
                        title: 'Driver Information',
                        icon: Icons.person,
                        children: [
                          _buildDetailRow(
                            icon: Icons.account_circle,
                            label: 'Name',
                            value: ride.driverName,
                          ),
                          _buildDetailRow(
                            icon: Icons.home,
                            label: 'Hostel',
                            value: ride.hostel,
                          ),
                          _buildDetailRow(
                            icon: Icons.phone,
                            label: 'Contact',
                            value: ride.phoneNumber,
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.copy,
                                size: 18,
                                color: AppColors.primaryYellow,
                              ),
                              onPressed: () => _copyToClipboard(
                                context,
                                ride.phoneNumber,
                                'Phone number',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'Trip Details',
                        icon: Icons.route,
                        children: [
                          _buildDetailRow(
                            icon: Icons.my_location,
                            label: 'From',
                            value: ride.from,
                          ),
                          _buildDetailRow(
                            icon: Icons.location_on,
                            label: 'To',
                            value: ride.to,
                          ),
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: ride.date,
                          ),
                          _buildDetailRow(
                            icon: Icons.access_time,
                            label: 'Time',
                            value: ride.time,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'Vehicle & Pricing',
                        icon: Icons.directions_car,
                        children: [
                          _buildDetailRow(
                            icon: Icons.drive_eta,
                            label: 'Vehicle Type',
                            value: ride.vehicleType,
                          ),
                          _buildDetailRow(
                            icon: Icons.event_seat,
                            label: 'Available Seats',
                            value: '${ride.availableSeats} seats',
                          ),
                          _buildDetailRow(
                            icon: Icons.currency_rupee,
                            label: 'Price per Seat',
                            value: ride.price,
                            valueColor: AppColors.accentGreen,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (ride.note.isNotEmpty)
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
                                ride.note,
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
    Widget? trailing,
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
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
