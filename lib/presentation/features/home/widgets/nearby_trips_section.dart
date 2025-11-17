import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../data/models/trip.dart';
import 'nearby_trip_tile.dart';
import 'empty_trips_widget.dart';
import 'nearby_trips_header.dart';

class NearbyTripsSection extends StatelessWidget {
  final List<Trip> availableTrips;
  final Position? userLocation;
  final bool isLoadingLocation;

  const NearbyTripsSection({
    super.key,
    required this.availableTrips,
    this.userLocation,
    required this.isLoadingLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NearbyTripsHeader(
          hasUserLocation: userLocation != null,
          isLoadingLocation: isLoadingLocation,
        ),
        const SizedBox(height: 2),
        
        availableTrips.isEmpty
            ? EmptyTripsWidget(
                isLoadingLocation: isLoadingLocation,
                hasUserLocation: userLocation != null,
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: availableTrips.length,
                itemBuilder: (context, index) {
                  final trip = availableTrips[index];
                  return NearbyTripTile(
                    trip: trip,
                    userLocation: userLocation,
                  );
                },
              ),
        
        const SizedBox(height: 100), // Bottom padding
      ],
    );
  }
}
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