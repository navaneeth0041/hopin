import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_request.dart';

class TripRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> createTripRequest({
    required String tripId,
    String? message,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return {'success': false, 'error': 'User profile not found'};
      }

      final userData = userDoc.data()!;
      final details = userData['details'] as Map<String, dynamic>?;

      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      if (!tripDoc.exists) {
        return {'success': false, 'error': 'Trip not found'};
      }

      final tripData = tripDoc.data()!;
      final creatorId = tripData['createdBy'];

      final requestId = _firestore.collection('tripRequests').doc().id;
      final request = TripRequest(
        id: requestId,
        tripId: tripId,
        requesterId: user.uid,
        requesterName: details?['fullName'] ?? 'Unknown User',
        requesterPhone: details?['phoneNumber'],
        requesterProfileImage: details?['profileImageBase64'],
        message: message,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('tripRequests')
          .doc(requestId)
          .set(request.toMap());

      await _createNotification(
        userId: creatorId,
        tripId: tripId,
        type: NotificationType.tripRequest,
        title: 'New Join Request',
        message: '${request.requesterName} wants to join your trip',
        data: {
          'requestId': requestId,
          'requesterId': user.uid,
          'requesterName': request.requesterName,
        },
      );

      return {
        'success': true,
        'requestId': requestId,
        'message': 'Request sent successfully',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> acceptTripRequest(String requestId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final requestDoc = await _firestore
          .collection('tripRequests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        return {'success': false, 'error': 'Request not found'};
      }

      final request = TripRequest.fromMap(requestDoc.data()!, requestId);

      final tripDoc = await _firestore
          .collection('trips')
          .doc(request.tripId)
          .get();

      if (!tripDoc.exists) {
        return {'success': false, 'error': 'Trip not found'};
      }

      final tripData = tripDoc.data()!;

      if (tripData['createdBy'] != user.uid) {
        return {
          'success': false,
          'error': 'Only trip creator can accept requests',
        };
      }

      return await _firestore
          .runTransaction((transaction) async {
            final freshTripDoc = await transaction.get(
              _firestore.collection('trips').doc(request.tripId),
            );

            if (!freshTripDoc.exists) {
              throw Exception('Trip not found');
            }

            final freshData = freshTripDoc.data()!;
            final availableSeats = freshData['availableSeats'] ?? 0;
            final joinedUsers = List<String>.from(
              freshData['joinedUsers'] ?? [],
            );

            if (availableSeats <= 0) {
              throw Exception('No available seats');
            }

            if (joinedUsers.contains(request.requesterId)) {
              throw Exception('User already joined');
            }

            transaction.update(
              _firestore.collection('tripRequests').doc(requestId),
              {
                'status': 'accepted',
                'respondedAt': FieldValue.serverTimestamp(),
              },
            );

            transaction.update(
              _firestore.collection('trips').doc(request.tripId),
              {
                'joinedUsers': FieldValue.arrayUnion([request.requesterId]),
                'availableSeats': availableSeats - 1,
                'status': availableSeats - 1 == 0 ? 'full' : 'active',
                'updatedAt': FieldValue.serverTimestamp(),
              },
            );

            return {
              'success': true,
              'message': 'Request accepted successfully',
            };
          })
          .then((result) async {
            await _createNotification(
              userId: request.requesterId,
              tripId: request.tripId,
              type: NotificationType.requestAccepted,
              title: 'Request Accepted',
              message: 'Your request to join the trip has been accepted',
              data: {'tripId': request.tripId, 'requestId': requestId},
            );

            final joinedUsers = List<String>.from(
              tripData['joinedUsers'] ?? [],
            );
            for (final memberId in joinedUsers) {
              if (memberId != request.requesterId) {
                await _createNotification(
                  userId: memberId,
                  tripId: request.tripId,
                  type: NotificationType.memberJoined,
                  title: 'New Member',
                  message: '${request.requesterName} joined the trip',
                );
              }
            }

            return result;
          })
          .catchError((error) {
            return {'success': false, 'error': error.toString()};
          });
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> rejectTripRequest(
    String requestId, {
    String? message,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final requestDoc = await _firestore
          .collection('tripRequests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        return {'success': false, 'error': 'Request not found'};
      }

      final request = TripRequest.fromMap(requestDoc.data()!, requestId);

      final tripDoc = await _firestore
          .collection('trips')
          .doc(request.tripId)
          .get();

      if (!tripDoc.exists) {
        return {'success': false, 'error': 'Trip not found'};
      }

      if (tripDoc.data()!['createdBy'] != user.uid) {
        return {
          'success': false,
          'error': 'Only trip creator can reject requests',
        };
      }

      await _firestore.collection('tripRequests').doc(requestId).update({
        'status': 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
        'responseMessage': message,
      });

      await _createNotification(
        userId: request.requesterId,
        tripId: request.tripId,
        type: NotificationType.requestRejected,
        title: 'Request Declined',
        message: message ?? 'Your request to join the trip was declined',
        data: {'tripId': request.tripId, 'requestId': requestId},
      );

      return {'success': true, 'message': 'Request rejected'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> cancelTripRequest(String requestId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final requestDoc = await _firestore
          .collection('tripRequests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        return {'success': false, 'error': 'Request not found'};
      }

      final request = TripRequest.fromMap(requestDoc.data()!, requestId);

      if (request.requesterId != user.uid) {
        return {
          'success': false,
          'error': 'You can only cancel your own requests',
        };
      }

      if (request.status != RequestStatus.pending) {
        return {'success': false, 'error': 'Can only cancel pending requests'};
      }

      await _firestore.collection('tripRequests').doc(requestId).update({
        'status': 'cancelled',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Request cancelled'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Stream<List<TripRequest>> getTripRequests(String tripId) {
    return _firestore
        .collection('tripRequests')
        .where('tripId', isEqualTo: tripId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TripRequest.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<List<TripRequest>> getUserPendingRequests(String userId) {
    return _firestore
        .collection('tripRequests')
        .where('requesterId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TripRequest.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<List<TripRequest>> getUserRequestHistory(String userId) {
    return _firestore
        .collection('tripRequests')
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TripRequest.fromMap(doc.data(), doc.id))
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

  Stream<List<TripNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TripNotification.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  Future<void> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
      rethrow;
    }
  }

  Stream<int> getUnreadNotificationsCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
