import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> submitReport({
    required String category,
    required String description,
    String? tripId,
    String? driverId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final reportId = _firestore.collection('reports').doc().id;
      final report = Report(
        id: reportId,
        userId: user.uid,
        category: _getCategoryFromTitle(category),
        description: description,
        status: ReportStatus.submitted,
        createdAt: DateTime.now(),
        tripId: tripId,
        driverId: driverId,
      );

      await _firestore.collection('reports').doc(reportId).set(report.toMap());

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reports')
          .doc(reportId)
          .set({
            'reportId': reportId,
            'category': category,
            'status': 'submitted',
            'createdAt': FieldValue.serverTimestamp(),
          });

      return {'success': true, 'reportId': reportId};
    } catch (e) {
      print('Error submitting report: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<List<Report>> getUserReports({int? limit}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No authenticated user');
        return [];
      }

      print('Fetching reports for user: ${user.uid}');

      Query query = _firestore
          .collection('reports')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      print('Found ${snapshot.docs.length} reports');

      return snapshot.docs.map((doc) {
        print('Report data: ${doc.data()}');
        return Report.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error getting user reports: $e');
      print('Error details: ${e.toString()}');
      return [];
    }
  }

  Future<Report?> getReportById(String reportId) async {
    try {
      final doc = await _firestore.collection('reports').doc(reportId).get();

      if (!doc.exists) return null;
      return Report.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting report: $e');
      return null;
    }
  }

  Future<bool> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('reports').doc(reportId).update({
        'status': Report.statusToString(status),
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == ReportStatus.resolved || status == ReportStatus.closed)
          'resolvedAt': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reports')
          .doc(reportId)
          .update({'status': Report.statusToString(status)});

      return true;
    } catch (e) {
      print('Error updating report status: $e');
      return false;
    }
  }

  Future<bool> deleteReport(String reportId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final report = await getReportById(reportId);
      if (report == null) return false;

      if (report.status != ReportStatus.submitted) {
        return false;
      }

      await _firestore.collection('reports').doc(reportId).delete();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reports')
          .doc(reportId)
          .delete();

      return true;
    } catch (e) {
      print('Error deleting report: $e');
      return false;
    }
  }

  Future<Map<String, int>> getReportsCountByStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final reports = await getUserReports();

      Map<String, int> counts = {
        'submitted': 0,
        'underReview': 0,
        'resolved': 0,
        'closed': 0,
      };

      for (var report in reports) {
        final statusKey = Report.statusToString(report.status);
        counts[statusKey] = (counts[statusKey] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error getting reports count: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> submitSupportTicket({
    required String email,
    required String description,
    String subject = 'General Support',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final ticketId = _firestore.collection('supportTickets').doc().id;
      final ticket = SupportTicket(
        id: ticketId,
        userId: user.uid,
        email: email,
        subject: subject,
        description: description,
        status: ReportStatus.submitted,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('supportTickets')
          .doc(ticketId)
          .set(ticket.toMap());

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('supportTickets')
          .doc(ticketId)
          .set({
            'ticketId': ticketId,
            'subject': subject,
            'status': 'submitted',
            'createdAt': FieldValue.serverTimestamp(),
          });

      return {'success': true, 'ticketId': ticketId};
    } catch (e) {
      print('Error submitting support ticket: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<List<SupportTicket>> getUserSupportTickets({int? limit}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      Query query = _firestore
          .collection('supportTickets')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => SupportTicket.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting support tickets: $e');
      return [];
    }
  }

  ReportCategory _getCategoryFromTitle(String title) {
    switch (title) {
      case 'Safety Concern':
        return ReportCategory.safetyConcern;
      case 'Driver Issue':
        return ReportCategory.driverIssue;
      case 'Vehicle Problem':
        return ReportCategory.vehicleProblem;
      case 'Payment Dispute':
        return ReportCategory.paymentDispute;
      case 'Route Problem':
        return ReportCategory.routeProblem;
      default:
        return ReportCategory.other;
    }
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
