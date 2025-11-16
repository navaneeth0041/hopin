import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hopin/data/models/trip_request.dart';
import '../models/trip.dart';
import 'trip_validation_service.dart';

class EnhancedTripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TripValidationService _validationService = TripValidationService();

  CollectionReference get _tripsCollection => _firestore.collection('trips');

  Future<Map<String, dynamic>> createTrip({
    required String currentLocation,
    required double currentLat,
    required double currentLng,
    required String destination,
    required double destLat,
    required double destLng,
    required DateTime departureTime,
    required DateTime endTime,
    required int availableSeats,
    String? note,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final validation = await _validationService.canCreateTrip(
        userId: user.uid,
        startTime: departureTime,
        endTime: endTime,
        seats: availableSeats,
        destination: destination,
        userLocation: Position(
          latitude: currentLat,
          longitude: currentLng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
        destinationLocation: Position(
          latitude: destLat,
          longitude: destLng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
      );

      if (!validation['valid']) {
        return {'success': false, 'error': validation['error']};
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data();
      final details = userData?['details'] as Map<String, dynamic>? ?? {};

      final userName = details['fullName'] ?? 'Unknown User';
      final userEmail = details['email'] ?? '';
      final userPhone = details['phoneNumber'] ?? '';
      final studentId = details['studentId'] ?? '';
      final department = details['department'] ?? '';
      final year = details['year'] ?? '';
      final profileImageUrl = details['profileImageUrl'];

      final now = DateTime.now();
      final tripId = _tripsCollection.doc().id;

      final trip = Trip(
        id: tripId,
        createdBy: user.uid,
        creatorName: userName,
        creatorProfileUrl: profileImageUrl,
        currentLocation: currentLocation,
        currentLat: currentLat,
        currentLng: currentLng,
        destination: destination,
        destLat: destLat,
        destLng: destLng,
        departureTime: departureTime,
        endTime: endTime,
        availableSeats: availableSeats,
        totalSeats: availableSeats,
        note: note,
        status: TripStatus.active,
        createdAt: now,
        updatedAt: now,
        joinedUsers: [],
        creatorDetails: {
          'email': userEmail,
          'phone': userPhone,
          'studentId': studentId,
          'department': department,
          'year': year,
        },
      );

      await _tripsCollection.doc(tripId).set(trip.toMap());

      return {
        'success': true,
        'tripId': tripId,
        'message': 'Trip created successfully',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> leaveTrip(String tripId, String userId) async {
    try {
      final tripDoc = await _tripsCollection.doc(tripId).get();
      if (!tripDoc.exists) {
        return {'success': false, 'error': 'Trip not found'};
      }

      final trip = Trip.fromMap(
        tripDoc.data() as Map<String, dynamic>,
        tripDoc.id,
      );

      if (trip.departureTime.isBefore(DateTime.now())) {
        return {
          'success': false,
          'error': 'Cannot leave a trip that has already started',
        };
      }

      if (trip.createdBy == userId) {
        return {
          'success': false,
          'error': 'As creator, you must cancel the trip instead of leaving',
        };
      }

      if (!trip.joinedUsers.contains(userId)) {
        return {'success': false, 'error': 'You are not part of this trip'};
      }

      await _tripsCollection.doc(tripId).update({
        'joinedUsers': FieldValue.arrayRemove([userId]),
        'availableSeats': FieldValue.increment(1),
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.data()?['details']?['fullName'] ?? 'A member';

      await _createNotification(
        userId: trip.createdBy,
        tripId: tripId,
        type: NotificationType.memberLeft,
        title: 'Member Left',
        message: '$userName has left the trip',
      );

      for (final memberId in trip.joinedUsers) {
        if (memberId != userId) {
          await _createNotification(
            userId: memberId,
            tripId: tripId,
            type: NotificationType.memberLeft,
            title: 'Member Left',
            message: '$userName has left the trip',
          );
        }
      }

      if (trip.joinedUsers.length == 1) {
        await _tripsCollection.doc(tripId).update({
          'status': 'active',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return {'success': true, 'message': 'You have left the trip'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> cancelTrip(String tripId, {bool autoCancel = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null && !autoCancel) return false;

      final tripDoc = await _tripsCollection.doc(tripId).get();
      if (!tripDoc.exists) return false;

      final trip = Trip.fromMap(
        tripDoc.data() as Map<String, dynamic>,
        tripDoc.id,
      );

      if (!autoCancel && trip.createdBy != user?.uid) {
        throw Exception('Only creator can cancel trip');
      }

      await _tripsCollection.doc(tripId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final message = autoCancel
          ? 'The trip has been automatically cancelled'
          : '${trip.creatorName} has cancelled the trip';

      for (final memberId in trip.joinedUsers) {
        await _createNotification(
          userId: memberId,
          tripId: tripId,
          type: NotificationType.tripCancelled,
          title: 'Trip Cancelled',
          message: message,
        );
      }

      final pendingRequests = await _firestore
          .collection('tripRequests')
          .where('tripId', isEqualTo: tripId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in pendingRequests.docs) {
        await doc.reference.update({
          'status': 'cancelled',
          'responseMessage': 'Trip was cancelled',
        });

        await _createNotification(
          userId: doc.data()['requesterId'],
          tripId: tripId,
          type: NotificationType.tripCancelled,
          title: 'Trip Cancelled',
          message: 'The trip you requested to join has been cancelled',
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeTrip(String tripId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final tripDoc = await _tripsCollection.doc(tripId).get();
      if (!tripDoc.exists) return false;

      final trip = Trip.fromMap(
        tripDoc.data() as Map<String, dynamic>,
        tripDoc.id,
      );

      if (trip.createdBy != user.uid) {
        throw Exception('Only creator can complete trip');
      }

      await _tripsCollection.doc(tripId).update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      });

      for (final memberId in trip.joinedUsers) {
        await _createNotification(
          userId: memberId,
          tripId: tripId,
          type: NotificationType.tripCompleted,
          title: 'Trip Completed',
          message: 'The trip has been marked as completed',
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Trip>> getUserTripHistory(String userId) {
    return _tripsCollection
        .where('status', whereIn: ['completed', 'cancelled'])
        .orderBy('departureTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .where(
                (trip) =>
                    trip.createdBy == userId ||
                    trip.joinedUsers.contains(userId),
              )
              .toList();
        });
  }

  Future<void> _createNotification({
    required String userId,
    required String tripId,
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId = _firestore.collection('notifications').doc().id;
      final notification = TripNotification(
        id: notificationId,
        userId: userId,
        tripId: tripId,
        type: type,
        title: title,
        message: message,
        data: data,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toMap());
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  Future<void> autoExpireOldTrips() async {
    try {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));

      final expiredTrips = await _tripsCollection
          .where('status', whereIn: ['active', 'full'])
          .where('departureTime', isLessThan: Timestamp.fromDate(twoHoursAgo))
          .get();

      for (final doc in expiredTrips.docs) {
        await doc.reference.update({
          'status': 'completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error auto-expiring trips: $e');
    }
  }
}
