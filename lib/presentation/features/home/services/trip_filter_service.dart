import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../data/models/trip.dart';
import '../../../../data/services/location_service.dart';

class TripFilterService {
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static List<Trip> filterAvailableTrips(
    List<Trip> allTrips, 
    Position? userLocation,
    {int lastLogTime = 0}
  ) {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      return [];
    }



    final filteredTrips = allTrips.where((trip) {
      if (trip.joinedUsers.contains(currentUserId)) {
        return false;
      }
      if (trip.status != TripStatus.active) {
        return false;
      }

      if (userLocation != null &&
          trip.currentLat != null &&
          trip.currentLng != null) {
        final distance = LocationService.calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          trip.currentLat!,
          trip.currentLng!,
        );

        final isWithinRadius = distance <= 2.0;
        if (!isWithinRadius) {
          return false;
        }
      }

      return true;
    }).toList();
    return filteredTrips;
  }

  static int getJoinableTripsCount(List<Trip> allTrips, Position? userLocation) {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null) return 0;

    final joinableTrips = allTrips.where((trip) {
      if (trip.createdBy == currentUserId) return false;
      if (trip.joinedUsers.contains(currentUserId)) return false;
      if (trip.status != TripStatus.active) return false;

      // Filter by 2km radius if user location is available
      if (userLocation != null &&
          trip.currentLat != null &&
          trip.currentLng != null) {
        final isWithinRadius = LocationService.isWithinRadius(
          userLocation.latitude,
          userLocation.longitude,
          trip.currentLat!,
          trip.currentLng!,
          2.0, // 2km radius
        );
        if (!isWithinRadius) return false;
      }

      return true;
    }).toList();

    return joinableTrips.length;
  }

  static String getPersonalizedTripMessage(List<Trip> allTrips, Position? userLocation) {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null) {
      return 'Searching for trips in your area...';
    }

    final ownTrips = allTrips
        .where(
          (trip) =>
              trip.createdBy == currentUserId &&
              trip.status == TripStatus.active,
        )
        .toList();

    final joinedTrips = allTrips
        .where(
          (trip) =>
              trip.joinedUsers.contains(currentUserId) &&
              trip.status == TripStatus.active,
        )
        .toList();

    final joinableTrips = getJoinableTripsCount(allTrips, userLocation);

    List<String> parts = [];

    if (ownTrips.isNotEmpty) {
      parts.add(
        '${ownTrips.length} trip${ownTrips.length > 1 ? 's' : ''} created',
      );
    }

    if (joinedTrips.isNotEmpty) {
      parts.add(
        '${joinedTrips.length} trip${joinedTrips.length > 1 ? 's' : ''} joined',
      );
    }

    if (joinableTrips > 0) {
      parts.add('${joinableTrips} available to join');
    }

    String message;
    if (parts.isEmpty) {
      message = 'No trips found. Create your first trip!';
    } else if (parts.length == 1) {
      message = parts.first;
    } else if (parts.length == 2) {
      message = '${parts[0]} • ${parts[1]}';
    } else {
      message = '${parts[0]} • ${parts[1]} • ${parts[2]}';
    }

    return message;
  }
}
