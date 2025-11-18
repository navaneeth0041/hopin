import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class TripValidationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  static const int maxActiveTripsAsCreator = 1;
  static const int maxTripsPerDay = 3;
  static const int maxJoinAttemptsPerDay = 10;
  static const int cooldownAfterCancellations = 2;
  static const int maxPendingRequests = 5;
  static const int maxSimultaneousActiveTrips = 2;

  static const double maxTripRadiusKm = 100.0;
  static const double localRegionRadiusKm = 50.0;

  static const int tripBufferMinutes = 30;

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
      final now = DateTime.now();
      if (startTime.isBefore(now)) {
        return {'valid': false, 'error': 'Start time cannot be in the past'};
      }

      if (startTime.isBefore(now.add(const Duration(minutes: 15)))) {
        return {
          'valid': false,
          'error': 'Trip must be scheduled at least 15 minutes in advance',
        };
      }

      if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
        return {'valid': false, 'error': 'End time must be after start time'};
      }

      final tripDuration = endTime.difference(startTime);
      if (tripDuration.inHours > 12) {
        return {
          'valid': false,
          'error': 'Trip duration cannot exceed 12 hours',
        };
      }

      if (tripDuration.inMinutes < 10) {
        return {
          'valid': false,
          'error': 'Trip duration must be at least 10 minutes',
        };
      }

      if (seats < 1 || seats > 6) {
        return {
          'valid': false,
          'error': 'Available seats must be between 1 and 6',
        };
      }

      if (destination.trim().isEmpty || destination.trim().length < 3) {
        return {
          'valid': false,
          'error': 'Please provide a valid destination (minimum 3 characters)',
        };
      }

      if (userLocation != null && destinationLocation != null) {
        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          destinationLocation.latitude,
          destinationLocation.longitude,
        );

        if (distance < 0.5) {
          return {
            'valid': false,
            'error':
                'Pickup and destination locations are too close (minimum 500m)',
          };
        }

        if (distance > maxTripRadiusKm) {
          return {
            'valid': false,
            'error':
                'Trip distance exceeds maximum allowed radius (${maxTripRadiusKm}km)',
          };
        }
      }

      final activeCreatorTrips = await _getActiveCreatorTrips(userId);
      if (activeCreatorTrips.isNotEmpty) {
        return {
          'valid': false,
          'error':
              'You already have an active trip. Complete or cancel it first.',
        };
      }

      final hasOverlap = await _hasOverlappingTrip(
        userId,
        startTime,
        endTime,
        includeBuffer: true,
      );
      if (hasOverlap) {
        return {
          'valid': false,
          'error':
              'This trip overlaps with another trip you\'re part of. Leave 30-minute gaps between trips.',
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
          'error': 'You already have a similar trip scheduled within 5 minutes',
        };
      }

      final rateLimitCheck = await _checkCreateRateLimit(userId);
      if (!rateLimitCheck['allowed']) {
        return {'valid': false, 'error': rateLimitCheck['error']};
      }

      final recentCancellations = await _getRecentCancellationsCount(userId);
      // if (recentCancellations >= cooldownAfterCancellations) {
      //   return {
      //     'valid': false,
      //     'error':
      //         'Too many recent cancellations. Please wait 24 hours before creating new trips.',
      //   };
      // } //uncomment

      final totalActiveParticipation = await _getTotalActiveParticipation(
        userId,
      );
      if (totalActiveParticipation >= maxSimultaneousActiveTrips) {
        return {
          'valid': false,
          'error':
              'You can only participate in $maxSimultaneousActiveTrips active trips at once',
        };
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
        return {'valid': false, 'error': 'Trip not found or has been deleted'};
      }

      final tripData = tripDoc.data()!;
      final startTime = (tripData['departureTime'] as Timestamp).toDate();
      final endTime = tripData['endTime'] != null
          ? (tripData['endTime'] as Timestamp).toDate()
          : startTime.add(const Duration(hours: 2));
      final availableSeats = tripData['availableSeats'] ?? 0;
      final creatorId = tripData['createdBy'] ?? '';
      final status = tripData['status'] ?? 'active';

      if (status != 'active') {
        return {
          'valid': false,
          'error': 'This trip is no longer available (Status: $status)',
        };
      }

      final now = DateTime.now();
      if (startTime.isBefore(now)) {
        return {
          'valid': false,
          'error': 'Cannot join a trip that has already started',
        };
      }

      if (startTime.difference(now).inMinutes < 10) {
        return {
          'valid': false,
          'error':
              'Trip is starting too soon. Join at least 10 minutes before departure.',
        };
      }

      if (availableSeats <= 0) {
        return {
          'valid': false,
          'error': 'No available seats. This trip is full.',
        };
      }

      if (creatorId == userId) {
        return {'valid': false, 'error': 'You cannot join your own trip'};
      }

      final joinedUsers = List<String>.from(tripData['joinedUsers'] ?? []);
      if (joinedUsers.contains(userId)) {
        return {'valid': false, 'error': 'You are already part of this trip'};
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

      final isBlocked = await _isBlockedByUser(userId, creatorId);
      if (isBlocked) {
        return {'valid': false, 'error': 'You cannot join this trip'};
      }

      final hasOverlap = await _hasOverlappingTrip(
        userId,
        startTime,
        endTime,
        includeBuffer: true,
      );
      if (hasOverlap) {
        return {
          'valid': false,
          'error':
              'This trip conflicts with another trip you\'re part of. Maintain 30-minute gaps.',
        };
      }

      final activeCreatorTrips = await _getActiveCreatorTrips(userId);
      if (activeCreatorTrips.isNotEmpty) {
        for (final creatorTrip in activeCreatorTrips) {
          // FIX: Convert Timestamp to DateTime
          final creatorStart = creatorTrip['departureTime'] is Timestamp
              ? (creatorTrip['departureTime'] as Timestamp).toDate()
              : creatorTrip['departureTime'] as DateTime;

          final creatorEnd = creatorTrip['endTime'] is Timestamp
              ? (creatorTrip['endTime'] as Timestamp).toDate()
              : creatorTrip['endTime'] as DateTime;

          if (_timeRangesOverlap(
            startTime,
            endTime,
            creatorStart,
            creatorEnd,
            includeBuffer: true,
          )) {
            return {
              'valid': false,
              'error':
                  'Cannot join this trip while you have an overlapping active trip as creator',
            };
          }
        }
      }

      final pendingCount = await _getUserPendingRequestsCount(userId);
      if (pendingCount >= maxPendingRequests) {
        return {
          'valid': false,
          'error':
              'You have reached the maximum pending requests ($maxPendingRequests). Wait for responses.',
        };
      }

      final rateLimitCheck = await _checkJoinRateLimit(userId);
      if (!rateLimitCheck['allowed']) {
        return {'valid': false, 'error': rateLimitCheck['error']};
      }

      final totalActiveParticipation = await _getTotalActiveParticipation(
        userId,
      );
      if (totalActiveParticipation >= maxSimultaneousActiveTrips) {
        return {
          'valid': false,
          'error':
              'You can only participate in $maxSimultaneousActiveTrips active trips at once',
        };
      }

      return {'valid': true};
    } catch (e) {
      return {'valid': false, 'error': 'Validation error: ${e.toString()}'};
    }
  }

  Future<List<Map<String, dynamic>>> _getActiveCreatorTrips(
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('trips')
          .where('createdBy', isEqualTo: userId)
          .where('status', whereIn: ['active', 'full'])
          .get();

      List<Map<String, dynamic>> activeTrips = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final departureTime = (data['departureTime'] as Timestamp).toDate();

        if (departureTime.isAfter(now) ||
            (data['endTime'] != null &&
                (data['endTime'] as Timestamp).toDate().isAfter(now))) {
          activeTrips.add({
            'id': doc.id,
            'departureTime': departureTime,
            'endTime': data['endTime'] != null
                ? (data['endTime'] as Timestamp).toDate()
                : departureTime.add(const Duration(hours: 2)),
            ...data,
          });
        }
      }

      return activeTrips;
    } catch (e) {
      return [];
    }
  }

  Future<int> _getTotalActiveParticipation(String userId) async {
    try {
      final now = DateTime.now();
      int count = 0;

      final creatorTrips = await _firestore
          .collection('trips')
          .where('createdBy', isEqualTo: userId)
          .where('status', whereIn: ['active', 'full'])
          .get();

      for (var doc in creatorTrips.docs) {
        final data = doc.data();
        final endTime = data['endTime'] != null
            ? (data['endTime'] as Timestamp).toDate()
            : (data['departureTime'] as Timestamp).toDate().add(
                const Duration(hours: 2),
              );

        if (endTime.isAfter(now)) {
          count++;
        }
      }

      final memberTrips = await _firestore
          .collection('trips')
          .where('joinedUsers', arrayContains: userId)
          .where('status', whereIn: ['active', 'full'])
          .get();

      for (var doc in memberTrips.docs) {
        final data = doc.data();
        final endTime = data['endTime'] != null
            ? (data['endTime'] as Timestamp).toDate()
            : (data['departureTime'] as Timestamp).toDate().add(
                const Duration(hours: 2),
              );

        if (endTime.isAfter(now)) {
          count++;
        }
      }

      return count;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> _isBlockedByUser(String userId, String otherUserId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(otherUserId)
          .collection('blockedUsers')
          .doc(userId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasOverlappingTrip(
    String userId,
    DateTime startTime,
    DateTime endTime, {
    bool includeBuffer = false,
  }) async {
    try {
      final now = DateTime.now();

      final checkStart = includeBuffer
          ? startTime.subtract(Duration(minutes: tripBufferMinutes))
          : startTime;
      final checkEnd = includeBuffer
          ? endTime.add(Duration(minutes: tripBufferMinutes))
          : endTime;

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

        if (tripEnd.isBefore(now)) continue;

        if (_timeRangesOverlap(checkStart, checkEnd, tripStart, tripEnd)) {
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

        if (tripEnd.isBefore(now)) continue;

        if (_timeRangesOverlap(checkStart, checkEnd, tripStart, tripEnd)) {
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
        if (data['destination']?.toString().toLowerCase().trim() ==
            destination.toLowerCase().trim()) {
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

      // if (tripsToday.docs.length >= maxTripsPerDay) {
      //   return {
      //     'allowed': false,
      //     'error':
      //         'Daily trip creation limit reached ($maxTripsPerDay per day). Try again tomorrow.',
      //   };
      // } // uncomment

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
          'error':
              'Daily join request limit reached ($maxJoinAttemptsPerDay per day). Try again tomorrow.',
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
    DateTime end2, {
    bool includeBuffer = false,
  }) {
    if (includeBuffer) {
      start1 = start1.subtract(Duration(minutes: tripBufferMinutes));
      end1 = end1.add(Duration(minutes: tripBufferMinutes));
      start2 = start2.subtract(Duration(minutes: tripBufferMinutes));
      end2 = end2.add(Duration(minutes: tripBufferMinutes));
    }

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
