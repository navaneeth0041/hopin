import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip.dart';

class TripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _tripsCollection => _firestore.collection('trips');

  Future<Trip?> getActiveUserTrip(String userId) async {
    try {
      final now = DateTime.now();

      final activeTrips = await _tripsCollection
          .where('createdBy', isEqualTo: userId)
          .where('status', whereIn: ['active', 'full'])
          .get();

      for (var doc in activeTrips.docs) {
        final trip = Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        if (trip.departureTime.isAfter(now)) {
          return trip;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasActiveTrip(String userId) async {
    try {
      final now = DateTime.now();

      final activeTrips = await _tripsCollection
          .where('createdBy', isEqualTo: userId)
          .where('status', whereIn: ['active', 'full'])
          .get();

      final futureTrips = activeTrips.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final departureTime = (data['departureTime'] as Timestamp).toDate();
        return departureTime.isAfter(now);
      }).toList();

      return futureTrips.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeTrip(String tripId) async {
    try {
      await _tripsCollection.doc(tripId).update({
        'status': 'completed',
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> createTrip({
    required String currentLocation,
    required String destination,
    required DateTime departureTime,
    required int availableSeats,
    String? note,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final hasActive = await hasActiveTrip(user.uid);
      if (hasActive) {
        throw Exception(
          'You already have an active trip. Complete or cancel it before creating a new one.',
        );
      }

      if (departureTime.isBefore(DateTime.now())) {
        throw Exception('Departure time must be in the future');
      }

      if (availableSeats < 1 || availableSeats > 6) {
        throw Exception('Available seats must be between 1 and 6');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data();
      if (userData == null) {
        throw Exception('User data is null');
      }

      final details = userData['details'] as Map<String, dynamic>? ?? {};

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
        destination: destination,
        departureTime: departureTime,
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

      await _updateUserTripCount(user.uid, isCreate: true);

      return tripId;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Trip>> getActiveTrips() {
    return _tripsCollection
        .where('status', isEqualTo: 'active')
        .where('departureTime', isGreaterThan: Timestamp.now())
        .orderBy('departureTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList();
        });
  }

  Stream<List<Trip>> getUserCreatedTrips(String userId) {
    return _tripsCollection
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList();
        });
  }

  Stream<List<Trip>> getUserJoinedTrips(String userId) {
    return _tripsCollection
        .where('joinedUsers', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList();
        });
  }

  Future<Trip?> getTripById(String tripId) async {
    try {
      final doc = await _tripsCollection.doc(tripId).get();
      if (doc.exists) {
        return Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateTrip(String tripId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _tripsCollection.doc(tripId).update(updates);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelTrip(String tripId) async {
    try {
      await _tripsCollection.doc(tripId).update({
        'status': 'cancelled',
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> joinTrip(String tripId, String userId) async {
    try {
      final tripDoc = await _tripsCollection.doc(tripId).get();
      if (!tripDoc.exists) return false;

      final trip = Trip.fromMap(
        tripDoc.data() as Map<String, dynamic>,
        tripDoc.id,
      );

      if (trip.availableSeats <= 0) {
        throw Exception('No available seats');
      }

      if (trip.joinedUsers.contains(userId)) {
        throw Exception('User already joined');
      }

      if (trip.createdBy == userId) {
        throw Exception('Cannot join your own trip');
      }

      final newAvailableSeats = trip.availableSeats - 1;
      final newStatus = newAvailableSeats == 0 ? 'full' : 'active';

      await _tripsCollection.doc(tripId).update({
        'joinedUsers': FieldValue.arrayUnion([userId]),
        'availableSeats': newAvailableSeats,
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> leaveTrip(String tripId, String userId) async {
    try {
      final tripDoc = await _tripsCollection.doc(tripId).get();
      if (!tripDoc.exists) return false;

      final trip = Trip.fromMap(
        tripDoc.data() as Map<String, dynamic>,
        tripDoc.id,
      );

      if (!trip.joinedUsers.contains(userId)) {
        throw Exception('User not in trip');
      }

      final newAvailableSeats = trip.availableSeats + 1;

      await _tripsCollection.doc(tripId).update({
        'joinedUsers': FieldValue.arrayRemove([userId]),
        'availableSeats': newAvailableSeats,
        'status': 'active',
        'updatedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Trip>> searchTripsByDestination(String destination) {
    return _tripsCollection
        .where('status', isEqualTo: 'active')
        .where('destination', isGreaterThanOrEqualTo: destination)
        .where('destination', isLessThanOrEqualTo: '$destination\uf8ff')
        .orderBy('destination')
        .orderBy('departureTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList();
        });
  }

  Future<bool> deleteTrip(String tripId, String userId) async {
    try {
      final tripDoc = await _tripsCollection.doc(tripId).get();
      if (!tripDoc.exists) return false;

      final trip = Trip.fromMap(
        tripDoc.data() as Map<String, dynamic>,
        tripDoc.id,
      );

      if (trip.createdBy != userId) {
        throw Exception('Only creator can delete trip');
      }

      await _tripsCollection.doc(tripId).delete();
      await _updateUserTripCount(userId, isCreate: false);

      return true;
    } catch (e) {
      print('Error deleting trip: $e');
      return false;
    }
  }

  Future<void> _updateUserTripCount(
    String userId, {
    required bool isCreate,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      if (isCreate) {
        await userRef.update({'tripsCreated': FieldValue.increment(1)});
      } else {
        await userRef.update({'tripsCreated': FieldValue.increment(-1)});
      }
    } catch (e) {
      return;
    }
  }

  Stream<List<Trip>> getUpcomingTripsForUser(String userId) {
    final now = Timestamp.now();

    return _tripsCollection
        .where('status', whereIn: ['active', 'full'])
        .where('departureTime', isGreaterThan: now)
        .orderBy('departureTime')
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
}
