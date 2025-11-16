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

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {

        Trip? activeTrip;
        
        final createdTrips = tripProvider.myCreatedTrips.where((trip) => 
          trip.status == TripStatus.active || trip.status == TripStatus.full).toList();
        
        if (createdTrips.isNotEmpty) {
          activeTrip = createdTrips.first;
        } else {
          final joinedTrips = tripProvider.myJoinedTrips.where((trip) => 
            trip.status == TripStatus.active || trip.status == TripStatus.full).toList();
          
          if (joinedTrips.isNotEmpty) {
            activeTrip = joinedTrips.first;
          }
        }

        if (activeTrip == null) {
          return const SizedBox.shrink();
        }

        final isOwnTrip = activeTrip.createdBy == currentUserId;

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
                      color: isOwnTrip ? Colors.blue : AppColors.primaryYellow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOwnTrip ? Icons.account_circle : Icons.person,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOwnTrip ? 'You (${activeTrip.creatorName})' : activeTrip.creatorName,
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


              // GestureDetector(
              //   onTap: () {
              //     showModalBottomSheet(
              //       context: context,
              //       isScrollControlled: true,
              //       backgroundColor: Colors.transparent,
              //       builder: (_) => RideDetailBottomSheet(ride: ride),
              //     );
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 14,
              //       vertical: 8,
              //     ),
              //     decoration: BoxDecoration(

              //       color: Colors.white.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(20),

              //       border: Border.all(
              //         color: Colors.white.withOpacity(0.2),
              //         width: 1,
              //       ),
              //     ),
              //     child: const Row(
              //       children: [
              //         Icon(
              //           Icons.info_outline,
              //           color: AppColors.textSecondary,
              //           size: 16,
              //         ),
              //         SizedBox(width: 6),
              //         Text(
              //           'Details',
              //           style: TextStyle(
              //             fontSize: 13,
              //             color: AppColors.textPrimary,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
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
                              activeTrip.currentLocation,
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
                              activeTrip.destination,
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
                            _formatDate(activeTrip.departureTime),
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
                            _formatTime(activeTrip.departureTime),
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
                            '${activeTrip.availableSeats} seats',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: activeTrip.status == TripStatus.active
                          ? AppColors.accentGreen.withOpacity(0.15)
                          : Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      activeTrip.status == TripStatus.active ? 'Active' : 
                      activeTrip.status == TripStatus.full ? 'Full' : 'Completed',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: activeTrip.status == TripStatus.active
                            ? AppColors.accentGreen
                            : Colors.orange,
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