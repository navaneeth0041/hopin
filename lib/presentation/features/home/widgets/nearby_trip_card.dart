// // lib/features/home/widgets/nearby_trip_card.dart
// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:hopin/core/constants/app_colors.dart';
// import 'package:hopin/data/models/home/nearby_trip_model.dart';

// class NearbyTripCard extends StatelessWidget {
//   final NearbyTripModel trip;

//   const NearbyTripCard({
//     super.key,
//     required this.trip,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: AppColors.divider,
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Creator Info Row
//           Row(
//             children: [
//               Container(
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryYellow,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child: Text(
//                     trip.creatorName[0],
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       trip.creatorName,
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.star_rounded,
//                           size: 14,
//                           color: AppColors.primaryYellow,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${trip.creatorRating}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.textSecondary,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryYellow.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   '${trip.matchPercentage}% Match',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primaryYellow,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Route visualization placeholder
//           Container(
//             width: double.infinity,
//             height: 80,
//             decoration: BoxDecoration(
//               color: AppColors.darkBackground,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: AppColors.divider,
//                 width: 1,
//               ),
//             ),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Map placeholder
//                 Icon(
//                   Icons.map_outlined,
//                   color: AppColors.textSecondary.withOpacity(0.5),
//                   size: 40,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),

//           // Route Details
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Pickup',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       'Your Location',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.textPrimary,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward,
//                 color: AppColors.textSecondary,
//                 size: 18,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Destination',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       trip.destination,
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.textPrimary,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Divider
//           Container(
//             height: 1,
//             color: AppColors.divider,
//           ),
//           const SizedBox(height: 12),

//           // Trip Details Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _TripDetailItem(
//                 icon: Icons.access_time,
//                 label: trip.departureTime,
//               ),
//               _TripDetailItem(
//                 icon: Icons.event_seat_outlined,
//                 label: trip.availableSeats,
//               ),
//               _TripDetailItem(
//                 icon: Icons.directions_walk,
//                 label: trip.distance,
//               ),
//               _TripDetailItem(
//                 icon: Icons.local_offer_outlined,
//                 label: trip.farePerPerson,
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Divider
//           Container(
//             height: 1,
//             color: AppColors.divider,
//           ),
//           const SizedBox(height: 12),

//           // Action Buttons
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.cardBackground,
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       side: BorderSide(
//                         color: AppColors.divider,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                             'View details for ${trip.destination}'),
//                       ),
//                     );
//                   },
//                   child: Text(
//                     'View Details',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryYellow,
//                     elevation: 4,
//                     shadowColor: AppColors.primaryYellow.withOpacity(0.4),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                             'Joined ${trip.destination} trip!'),
//                       ),
//                     );
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.check_circle_outline,
//                         color: Colors.black,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         'Quick Join',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TripDetailItem extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const _TripDetailItem({
//     required this.icon,
//     required this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         children: [
//           Icon(
//             icon,
//             color: AppColors.primaryYellow,
//             size: 20,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textPrimary,
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }