import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> sendPaymentReminder({
    required String tripId,
    required String creatorId,
    required String creatorName,
    required double amount,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['details']?['fullName'] ?? 'A member';

      final recentReminders = await _firestore
          .collection('paymentReminders')
          .where('tripId', isEqualTo: tripId)
          .where('reminderId', isEqualTo: user.uid)
          .where('creatorId', isEqualTo: creatorId)
          .orderBy('sentAt', descending: true)
          .limit(1)
          .get();

      if (recentReminders.docs.isNotEmpty) {
        final lastReminder = recentReminders.docs.first.data();
        final lastSentAt = (lastReminder['sentAt'] as Timestamp).toDate();
        final hoursSinceLastReminder = 
            DateTime.now().difference(lastSentAt).inHours;

        if (hoursSinceLastReminder < 24) {
          return {
            'success': false,
            'error': 'You can send another reminder in ${24 - hoursSinceLastReminder} hours',
          };
        }
      }

      final notificationId = _firestore.collection('notifications').doc().id;
      await _firestore.collection('notifications').doc(notificationId).set({
        'userId': creatorId,
        'tripId': tripId,
        'type': 'payment_reminder',
        'title': 'Payment Reminder',
        'message': '$userName has reminded you to mark their payment of ₹${amount.toStringAsFixed(2)} as received',
        'data': {
          'reminderId': user.uid,
          'reminderName': userName,
          'amount': amount,
          'paymentId': null, 
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('paymentReminders').add({
        'tripId': tripId,
        'reminderId': user.uid,
        'reminderName': userName,
        'creatorId': creatorId,
        'amount': amount,
        'sentAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Reminder sent to $creatorName successfully',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<DateTime?> getLastReminderTime({
    required String tripId,
    required String creatorId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final reminders = await _firestore
          .collection('paymentReminders')
          .where('tripId', isEqualTo: tripId)
          .where('reminderId', isEqualTo: user.uid)
          .where('creatorId', isEqualTo: creatorId)
          .orderBy('sentAt', descending: true)
          .limit(1)
          .get();

      if (reminders.docs.isEmpty) return null;

      return (reminders.docs.first.data()['sentAt'] as Timestamp).toDate();
    } catch (e) {
      return null;
    }
  }

  Future<bool> canSendReminder({
    required String tripId,
    required String creatorId,
  }) async {
    final lastReminder = await getLastReminderTime(
      tripId: tripId,
      creatorId: creatorId,
    );

    if (lastReminder == null) return true;

    final hoursSince = DateTime.now().difference(lastReminder).inHours;
    return hoursSince >= 24;
  }

  Future<Duration?> getTimeUntilNextReminder({
    required String tripId,
    required String creatorId,
  }) async {
    final lastReminder = await getLastReminderTime(
      tripId: tripId,
      creatorId: creatorId,
    );

    if (lastReminder == null) return null;

    final nextReminderTime = lastReminder.add(const Duration(hours: 24));
    final now = DateTime.now();

    if (now.isAfter(nextReminderTime)) return null;

    return nextReminderTime.difference(now);
  }
}