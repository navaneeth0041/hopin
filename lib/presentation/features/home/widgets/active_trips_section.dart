// // lib/features/home/widgets/active_trips_section.dart
// import 'package:flutter/material.dart';
// import 'package:hopin/core/constants/app_colors.dart';
// import 'package:hopin/data/models/home/trip_model.dart';
// import 'trip_card.dart';

// class ActiveTripsSection extends StatelessWidget {
//   const ActiveTripsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Mock data - replace with real data from provider/bloc
//     final activeTrips = [
//       TripModel(
//         id: '1',
//         destination: 'Fort Kochi',
//         date: '15 Oct, 2024',
//         time: '2:30 PM',
//         participants: '2/4',
//         fareShare: '₹125',
//         status: TripStatus.confirmed,
//       ),
//       TripModel(
//         id: '2',
//         destination: 'Ernakulathappan',
//         date: '15 Oct, 2024',
//         time: '4:00 PM',
//         participants: '3/4',
//         fareShare: '₹95',
//         status: TripStatus.waiting,
//       ),
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Your Active Trips',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(const SnackBar(content: Text('View All Trips')));
//               },
//               child: Text(
//                 'See All',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: AppColors.primaryYellow,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         activeTrips.isEmpty
//             ? _EmptyState(
//                 icon: Icons.directions_car_outlined,
//                 title: 'No Active Trips',
//                 subtitle: 'Create or join a trip to get started',
//               )
//             : ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: activeTrips.length,
//                 itemBuilder: (context, index) => Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: TripCard(trip: activeTrips[index]),
//                 ),
//               ),
//       ],
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;

//   const _EmptyState({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.divider, width: 1),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: AppColors.textSecondary, size: 48),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             subtitle,
//             style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/trip.dart';
import 'package:hopin/data/providers/trip_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
// import 'ride_detail_bottom_sheet.dart';

class ActiveRideCard extends StatelessWidget {
  const ActiveRideCard({super.key});

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour == 0 ? 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }

  Future<Widget> _buildProfileImage(String userId, String name, bool isOwnTrip) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final details = userData?['details'] as Map<String, dynamic>?;
        final profileImageBase64 = details?['profileImageBase64'] as String?;

        if (profileImageBase64 != null && profileImageBase64.isNotEmpty) {
          try {
            final Uint8List bytes = base64Decode(profileImageBase64);
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: MemoryImage(bytes),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: isOwnTrip ? Colors.blue.shade300 : AppColors.primaryYellow,
                  width: 2,
                ),
              ),
            );
          } catch (e) {
            return _buildInitials(name, isOwnTrip);
          }
        }
      }
    } catch (e) {
      return _buildInitials(name, isOwnTrip);
    }

    return _buildInitials(name, isOwnTrip);
  }

  Widget _buildInitials(String name, bool isOwnTrip) {
    final initials = name.isNotEmpty 
      ? name.split(' ').map((n) => n.isNotEmpty ? n[0].toUpperCase() : '').take(2).join('')
      : 'U';
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOwnTrip 
            ? [Colors.blue.shade300, Colors.blue.shade500]
            : [AppColors.primaryYellow.withOpacity(0.8), AppColors.primaryYellow],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isOwnTrip ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {

        Trip? activeTrip;
        
        final createdTrips = tripProvider.myCreatedTrips.where((trip) => 
          trip.status == TripStatus.active).toList();
        
        if (createdTrips.isNotEmpty) {
          activeTrip = createdTrips.first;
        } else {
          final joinedTrips = tripProvider.myJoinedTrips.where((trip) => 
            trip.status == TripStatus.active).toList();
          
          if (joinedTrips.isNotEmpty) {
            activeTrip = joinedTrips.first;
          }
        }

        if (activeTrip == null) {
          return const SizedBox(height: 0, width: 0);
        }

        final Trip trip = activeTrip;
        final isOwnTrip = trip.createdBy == currentUserId;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isOwnTrip 
                          ? [Colors.blue.shade400, Colors.blue.shade600]
                          : [AppColors.primaryYellow, AppColors.primaryYellow.withOpacity(0.8)],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: FutureBuilder<Widget>(
                        future: _buildProfileImage(trip.createdBy, trip.creatorName, isOwnTrip),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data!;
                          }
                          return _buildInitials(trip.creatorName, isOwnTrip);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOwnTrip ? 'You (${trip.creatorName})' : trip.creatorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOwnTrip ? 'Trip Creator' : 'Trip Member',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

            ],
          ),

          const SizedBox(height: 14),


                  const SizedBox(height: 14),

                  // Route information
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'From',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              trip.currentLocation,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'To',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              trip.destination,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Trip details row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(trip.departureTime),
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(trip.departureTime),
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.event_seat,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${trip.availableSeats} seats',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }
}