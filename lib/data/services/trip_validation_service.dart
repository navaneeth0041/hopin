import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class TripValidationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  static const int maxTripsPerDay = 3;
  static const int maxJoinAttemptsPerDay = 10;
  static const int cooldownAfterCancellations = 2;
  static const int maxPendingRequests = 5;

  static const double maxTripRadiusKm = 100.0;
  static const double localRegionRadiusKm = 50.0;

  Future<Map<String, dynamic>> canCreateTrip({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
    required int seats,
    required String destination,
    required Position? userLocation,
    required Position? destinationLocation,
  }) async {
    try {
      if (startTime.isBefore(DateTime.now())) {
        return {'valid': false, 'error': 'Start time cannot be in the past'};
      }

      if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
        return {'valid': false, 'error': 'End time must be after start time'};
      }

      if (seats < 1 || seats > 6) {
        return {'valid': false, 'error': 'Seats must be between 1 and 6'};
      }

      if (destination.trim().isEmpty) {
        return {'valid': false, 'error': 'Destination cannot be empty'};
      }

      if (userLocation != null && destinationLocation != null) {
        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          destinationLocation.latitude,
          destinationLocation.longitude,
        );

        if (distance > maxTripRadiusKm) {
          return {
            'valid': false,
            'error':
                'Trip distance exceeds maximum allowed radius (${maxTripRadiusKm}km)',
          };
        }
      }

      final hasOverlap = await _hasOverlappingTrip(userId, startTime, endTime);
      if (hasOverlap) {
        return {
          'valid': false,
          'error': 'You already have an active trip during this time',
        };
      }

      final hasDuplicate = await _hasDuplicateTrip(
        userId,
        startTime,
        destination,
      );
      if (hasDuplicate) {
        return {
          'valid': false,
          'error':
              'A similar trip already exists within 5 minutes of this time',
        };
      }

      final rateLimitCheck = await _checkCreateRateLimit(userId);
      if (!rateLimitCheck['allowed']) {
        return {'valid': false, 'error': rateLimitCheck['error']};
      }

      return {'valid': true};
    } catch (e) {
      return {'valid': false, 'error': 'Validation error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> canJoinTrip({
    required String userId,
    required String tripId,
  }) async {
    try {
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      if (!tripDoc.exists) {
        return {'valid': false, 'error': 'Trip not found'};
      }

      final tripData = tripDoc.data()!;
      final startTime = (tripData['departureTime'] as Timestamp).toDate();
      final endTime = tripData['endTime'] != null
          ? (tripData['endTime'] as Timestamp).toDate()
          : startTime.add(const Duration(hours: 2));
      final availableSeats = tripData['availableSeats'] ?? 0;
      final creatorId = tripData['createdBy'] ?? '';

      if (startTime.isBefore(DateTime.now())) {
        return {
          'valid': false,
          'error': 'Cannot join a trip that has already started',
        };
      }

      if (availableSeats <= 0) {
        return {'valid': false, 'error': 'No available seats'};
      }

      if (creatorId == userId) {
        return {'valid': false, 'error': 'You cannot join your own trip'};
      }

      final existingRequest = await _firestore
          .collection('tripRequests')
          .where('tripId', isEqualTo: tripId)
          .where('requesterId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        return {
          'valid': false,
          'error': 'You already have a pending request for this trip',
        };
      }

      final joinedUsers = List<String>.from(tripData['joinedUsers'] ?? []);
      if (joinedUsers.contains(userId)) {
        return {'valid': false, 'error': 'You are already part of this trip'};
      }

      final hasOverlap = await _hasOverlappingTrip(userId, startTime, endTime);
      if (hasOverlap) {
        return {
          'valid': false,
          'error': 'You have another trip during this time',
        };
      }

      final pendingCount = await _getUserPendingRequestsCount(userId);
      if (pendingCount >= maxPendingRequests) {
        return {
          'valid': false,
          'error':
              'You have reached the maximum pending requests ($maxPendingRequests)',
        };
      }

      final rateLimitCheck = await _checkJoinRateLimit(userId);
      if (!rateLimitCheck['allowed']) {
        return {'valid': false, 'error': rateLimitCheck['error']};
      }

      return {'valid': true};
    } catch (e) {
      return {'valid': false, 'error': 'Validation error: ${e.toString()}'};
    }
  }

  Future<bool> _hasOverlappingTrip(
    String userId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final activeTrips = await _firestore
          .collection('trips')
          .where('createdBy', isEqualTo: userId)
          .where('status', whereIn: ['active', 'full'])
          .get();

      for (var doc in activeTrips.docs) {
        final data = doc.data();
        final tripStart = (data['departureTime'] as Timestamp).toDate();
        final tripEnd = data['endTime'] != null
            ? (data['endTime'] as Timestamp).toDate()
            : tripStart.add(const Duration(hours: 2));

        if (_timeRangesOverlap(startTime, endTime, tripStart, tripEnd)) {
          return true;
        }
      }

      final joinedTrips = await _firestore
          .collection('trips')
          .where('joinedUsers', arrayContains: userId)
          .where('status', whereIn: ['active', 'full'])
          .get();

      for (var doc in joinedTrips.docs) {
        final data = doc.data();
        final tripStart = (data['departureTime'] as Timestamp).toDate();
        final tripEnd = data['endTime'] != null
            ? (data['endTime'] as Timestamp).toDate()
            : tripStart.add(const Duration(hours: 2));

        if (_timeRangesOverlap(startTime, endTime, tripStart, tripEnd)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasDuplicateTrip(
    String userId,
    DateTime startTime,
    String destination,
  ) async {
    try {
      final fiveMinBefore = startTime.subtract(const Duration(minutes: 5));
      final fiveMinAfter = startTime.add(const Duration(minutes: 5));

      final snapshot = await _firestore
          .collection('trips')
          .where('createdBy', isEqualTo: userId)
          .where('status', whereIn: ['active', 'full'])
          .where(
            'departureTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fiveMinBefore),
          )
          .where(
            'departureTime',
            isLessThanOrEqualTo: Timestamp.fromDate(fiveMinAfter),
          )
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['destination']?.toString().toLowerCase() ==
            destination.toLowerCase()) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _checkCreateRateLimit(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final tripsToday = await _firestore
          .collection('trips')
          .where('createdBy', isEqualTo: userId)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .get();

      if (tripsToday.docs.length >= maxTripsPerDay) {
        return {
          'allowed': false,
          'error':
              'Daily trip creation limit reached ($maxTripsPerDay per day)',
        };
      }

      final recentCancellations = await _getRecentCancellationsCount(userId);
      if (recentCancellations >= cooldownAfterCancellations) {
        return {
          'allowed': false,
          'error':
              'Too many recent cancellations. Please wait before creating a new trip.',
        };
      }

      return {'allowed': true};
    } catch (e) {
      return {'allowed': true};
    }
  }

  Future<Map<String, dynamic>> _checkJoinRateLimit(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final requestsToday = await _firestore
          .collection('tripRequests')
          .where('requesterId', isEqualTo: userId)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .get();

      if (requestsToday.docs.length >= maxJoinAttemptsPerDay) {
        return {
          'allowed': false,
          'error': 'Daily join limit reached ($maxJoinAttemptsPerDay per day)',
        };
      }

      return {'allowed': true};
    } catch (e) {
      return {'allowed': true};
    }
  }

  Future<int> _getRecentCancellationsCount(String userId) async {
    try {
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('trips')
          .where('createdBy', isEqualTo: userId)
          .where('status', isEqualTo: 'cancelled')
          .where(
            'updatedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo),
          )
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getUserPendingRequestsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tripRequests')
          .where('requesterId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  bool _timeRangesOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
