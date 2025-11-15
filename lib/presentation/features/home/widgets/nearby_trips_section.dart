// import 'package:flutter/material.dart';
// import 'package:hopin/core/constants/app_colors.dart';
// import 'package:hopin/data/models/home/nearby_trip_model.dart';
// import 'nearby_trip_card.dart';

// class NearbyTripsSection extends StatefulWidget {
//   const NearbyTripsSection({super.key});

//   @override
//   State<NearbyTripsSection> createState() => _NearbyTripsSectionState();
// }

// class _NearbyTripsSectionState extends State<NearbyTripsSection> {
//   String _selectedFilter = 'All';
//   final List<String> _filterOptions = ['All', 'Today', 'Tomorrow', 'This Week'];

//   @override
//   Widget build(BuildContext context) {
//     final nearbyTrips = [
//       NearbyTripModel(
//         id: '1',
//         creatorName: 'Hashim Hanifa',
//         creatorRating: 4.5,
//         destination: 'Gold Souk',
//         departureTime: '2:45 PM',
//         availableSeats: '2/4',
//         farePerPerson: '₹150',
//         matchPercentage: 85,
//         distance: '2.3 km away',
//         routeImage: 'assets/route_1.png',
//       ),
//       NearbyTripModel(
//         id: '2',
//         creatorName: '',
//         creatorRating: 4.8,
//         destination: 'Lulu Mall',
//         departureTime: '3:15 PM',
//         availableSeats: '1/4',
//         farePerPerson: '₹120',
//         matchPercentage: 92,
//         distance: '1.8 km away',
//         routeImage: 'assets/route_2.png',
//       ),
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Rides Near You',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: AppColors.textPrimary,
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Navigate to Find Rides Page')),
//                 );
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

//         // Filter Chips
//         SizedBox(
//           height: 40,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: _filterOptions.length,
//             itemBuilder: (context, index) {
//               final option = _filterOptions[index];
//               final isSelected = _selectedFilter == option;

//               return Padding(
//                 padding: EdgeInsets.only(right: index < _filterOptions.length - 1 ? 8 : 0),
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _selectedFilter = option;
//                     });
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: isSelected ? AppColors.primaryYellow : AppColors.cardBackground,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: isSelected ? Colors.transparent : AppColors.divider,
//                         width: 1,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         option,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: isSelected ? Colors.black : AppColors.textPrimary,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 16),

//         // Nearby Trips List
//         nearbyTrips.isEmpty
//             ? Container(
//                 padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//                 decoration: BoxDecoration(
//                   color: AppColors.cardBackground,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: AppColors.divider,
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.search_outlined,
//                       color: AppColors.textSecondary,
//                       size: 48,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No Rides Available',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Try adjusting your filters or create a trip',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: AppColors.textSecondary,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               )
//             : ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: nearbyTrips.length,
//                 itemBuilder: (context, index) => Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: NearbyTripCard(trip: nearbyTrips[index]),
//                 ),
//               ),
//       ],
//     );
//   }
// }