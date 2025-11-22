import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_payment_model.dart';

class TripPaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> createTripPayment({
    required String tripId,
    required double totalAmount,
    required List<String> memberIds,
    required Map<String, String> memberNames,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      if (totalAmount <= 0) {
        return {'success': false, 'error': 'Amount must be greater than 0'};
      }

      final totalMembers = memberIds.length + 1;
      final perPersonShare = totalAmount / totalMembers;

      final memberPayments = <String, MemberPayment>{};
      for (final memberId in memberIds) {
        memberPayments[memberId] = MemberPayment(
          userId: memberId,
          userName: memberNames[memberId] ?? 'Unknown',
          amountDue: perPersonShare,
          status: PaymentStatus.pending,
        );
      }

      final paymentId = _firestore.collection('tripPayments').doc().id;
      final payment = TripPayment(
        id: paymentId,
        tripId: tripId,
        creatorId: user.uid,
        totalAmount: totalAmount,
        completedAt: DateTime.now(),
        memberPayments: memberPayments,
        isFullyPaid: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('tripPayments')
          .doc(paymentId)
          .set(payment.toMap());

      for (final memberId in memberIds) {
        await _updateUserPaymentRecord(
          memberId,
          tripId,
          perPersonShare,
          isAdding: true,
        );
      }

      await _sendPaymentNotifications(
        tripId: tripId,
        memberIds: memberIds,
        perPersonShare: perPersonShare,
        totalAmount: totalAmount,
      );

      return {
        'success': true,
        'paymentId': paymentId,
        'perPersonShare': perPersonShare,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> markMemberAsPaid({
    required String paymentId,
    required String memberId,
    String? note,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final paymentDoc = await _firestore
          .collection('tripPayments')
          .doc(paymentId)
          .get();

      if (!paymentDoc.exists) {
        return {'success': false, 'error': 'Payment record not found'};
      }

      final payment = TripPayment.fromMap(paymentDoc.data()!);

      if (payment.creatorId != user.uid) {
        return {
          'success': false,
          'error': 'Only trip creator can mark payments',
        };
      }

      final updatedMemberPayment = payment.memberPayments[memberId]?.copyWith(
        status: PaymentStatus.paid,
        paidAt: DateTime.now(),
        markedPaidBy: DateTime.now(),
        note: note,
      );

      if (updatedMemberPayment == null) {
        return {
          'success': false,
          'error': 'Member not found in payment record',
        };
      }

      final updatedMemberPayments = Map<String, MemberPayment>.from(
        payment.memberPayments,
      );
      updatedMemberPayments[memberId] = updatedMemberPayment;

      final allPaid = updatedMemberPayments.values.every(
        (p) => p.status == PaymentStatus.paid,
      );

      await _firestore.collection('tripPayments').doc(paymentId).update({
        'memberPayments.$memberId': updatedMemberPayment.toMap(),
        'isFullyPaid': allPaid,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      await _updateUserPaymentRecord(
        memberId,
        payment.tripId,
        updatedMemberPayment.amountDue,
        isAdding: false,
      );

      await _sendPaymentConfirmationNotification(
        tripId: payment.tripId,
        userId: memberId,
        amount: updatedMemberPayment.amountDue,
      );

      return {'success': true, 'allPaid': allPaid};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> checkUserPaymentStatus(String userId) async {
    try {
      final doc = await _firestore
          .collection('userPaymentRecords')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return {
          'hasUnpaidTrips': false,
          'unpaidCount': 0,
          'totalUnpaid': 0.0,
          'unpaidTripIds': <String>[],
        };
      }

      final record = UserPaymentRecord.fromMap(doc.data()!);

      return {
        'hasUnpaidTrips': record.hasUnpaidTrips,
        'unpaidCount': record.unpaidTripIds.length,
        'totalUnpaid': record.totalUnpaidAmount,
        'unpaidTripIds': record.unpaidTripIds,
      };
    } catch (e) {
      return {
        'hasUnpaidTrips': false,
        'unpaidCount': 0,
        'totalUnpaid': 0.0,
        'unpaidTripIds': <String>[],
        'error': e.toString(),
      };
    }
  }

  Future<TripPayment?> getTripPayment(String tripId) async {
    try {
      final snapshot = await _firestore
          .collection('tripPayments')
          .where('tripId', isEqualTo: tripId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return TripPayment.fromMap(snapshot.docs.first.data());
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserUnpaidTripDetails(
    String userId,
  ) async {
    try {
      final recordDoc = await _firestore
          .collection('userPaymentRecords')
          .doc(userId)
          .get();

      if (!recordDoc.exists) return [];

      final record = UserPaymentRecord.fromMap(recordDoc.data()!);
      final unpaidDetails = <Map<String, dynamic>>[];

      for (final tripId in record.unpaidTripIds) {
        final payment = await getTripPayment(tripId);
        if (payment != null) {
          final memberPayment = payment.memberPayments[userId];
          if (memberPayment != null) {
            final tripDoc = await _firestore
                .collection('trips')
                .doc(tripId)
                .get();

            final tripData = tripDoc.data();

            unpaidDetails.add({
              'tripId': tripId,
              'amount': memberPayment.amountDue,
              'tripDestination': tripData?['destination'] ?? 'Unknown',
              'tripDate': payment.completedAt,
              'creatorName': tripData?['creatorName'] ?? 'Unknown',
            });
          }
        }
      }

      return unpaidDetails;
    } catch (e) {
      return [];
    }
  }

  Future<void> _updateUserPaymentRecord(
    String userId,
    String tripId,
    double amount, {
    required bool isAdding,
  }) async {
    final docRef = _firestore.collection('userPaymentRecords').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        if (isAdding) {
          transaction.set(
            docRef,
            UserPaymentRecord(
              userId: userId,
              unpaidTripIds: [tripId],
              totalUnpaidAmount: amount,
            ).toMap(),
          );
        }
      } else {
        final record = UserPaymentRecord.fromMap(doc.data()!);
        final updatedTripIds = List<String>.from(record.unpaidTripIds);
        double updatedAmount = record.totalUnpaidAmount;

        if (isAdding) {
          if (!updatedTripIds.contains(tripId)) {
            updatedTripIds.add(tripId);
            updatedAmount += amount;
          }
        } else {
          updatedTripIds.remove(tripId);
          updatedAmount -= amount;
          if (updatedAmount < 0) updatedAmount = 0;
        }

        transaction.update(docRef, {
          'unpaidTripIds': updatedTripIds,
          'totalUnpaidAmount': updatedAmount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> _sendPaymentNotifications({
    required String tripId,
    required List<String> memberIds,
    required double perPersonShare,
    required double totalAmount,
  }) async {
    for (final memberId in memberIds) {
      try {
        final notificationId = _firestore.collection('notifications').doc().id;
        await _firestore.collection('notifications').doc(notificationId).set({
          'userId': memberId,
          'tripId': tripId,
          'type': 'payment_due',
          'title': 'Trip Payment Due',
          'message':
              'Your share is ₹${perPersonShare.toStringAsFixed(2)} for the completed trip',
          'data': {
            'amount': perPersonShare,
            'totalAmount': totalAmount,
            'dueDate': DateTime.now()
                .add(const Duration(days: 7))
                .toIso8601String(),
          },
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error sending payment notification to $memberId: $e');
      }
    }
  }

  Future<void> _sendPaymentConfirmationNotification({
    required String tripId,
    required String userId,
    required double amount,
  }) async {
    try {
      final notificationId = _firestore.collection('notifications').doc().id;
      await _firestore.collection('notifications').doc(notificationId).set({
        'userId': userId,
        'tripId': tripId,
        'type': 'payment_confirmed',
        'title': 'Payment Confirmed',
        'message':
            'Your payment of ₹${amount.toStringAsFixed(2)} has been confirmed',
        'data': {'amount': amount},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      return;
    }
  }

  Future<Map<String, dynamic>> raisePaymentDispute({
    required String paymentId,
    required String reason,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final paymentDoc = await _firestore
          .collection('tripPayments')
          .doc(paymentId)
          .get();

      if (!paymentDoc.exists) {
        return {'success': false, 'error': 'Payment record not found'};
      }

      final payment = TripPayment.fromMap(paymentDoc.data()!);
      final memberPayment = payment.memberPayments[user.uid];

      if (memberPayment == null) {
        return {'success': false, 'error': 'You are not part of this payment'};
      }

      await _firestore.collection('tripPayments').doc(paymentId).update({
        'memberPayments.${user.uid}.status': 'disputed',
        'memberPayments.${user.uid}.note': reason,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('notifications').add({
        'userId': payment.creatorId,
        'tripId': payment.tripId,
        'type': 'payment_disputed',
        'title': 'Payment Disputed',
        'message': '${memberPayment.userName} has disputed the payment',
        'data': {'reason': reason, 'disputedBy': user.uid},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
