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
import 'package:hopin/data/models/home/ride_model.dart';
// import 'ride_detail_bottom_sheet.dart';

class ActiveRideCard extends StatelessWidget {
  const ActiveRideCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Pick the first ride from mock data (or any default)
    final ride = RideModelMockData.getMockRides().first;

    return Container(
  
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(

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
                decoration: const BoxDecoration(
                  color: AppColors.primaryYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.black, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.driverName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ride.hostel,
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
                      ride.from,
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
                      ride.to,
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
                    ride.date,
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
                    ride.time,
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
                    '${ride.availableSeats} seats',
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
              color: ride.status == 'Confirmed'
                  ? AppColors.accentGreen.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ride.status,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ride.status == 'Confirmed'
                    ? AppColors.accentGreen
                    : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}