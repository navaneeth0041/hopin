import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_payment_model.dart';
import '../services/trip_payment_service.dart';

class TripPaymentProvider extends ChangeNotifier {
  final TripPaymentService _service = TripPaymentService();

  bool _isLoading = false;
  String? _errorMessage;
  TripPayment? _currentPayment;
  UserPaymentRecord? _userPaymentRecord;
  List<Map<String, dynamic>> _unpaidTripDetails = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TripPayment? get currentPayment => _currentPayment;
  UserPaymentRecord? get userPaymentRecord => _userPaymentRecord;
  List<Map<String, dynamic>> get unpaidTripDetails => _unpaidTripDetails;

  bool get hasUnpaidTrips => _userPaymentRecord?.hasUnpaidTrips ?? false;

  Future<Map<String, dynamic>> createPayment({
    required String tripId,
    required double totalAmount,
    required List<String> memberIds,
    required Map<String, String> memberNames,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _service.createTripPayment(
        tripId: tripId,
        totalAmount: totalAmount,
        memberIds: memberIds,
        memberNames: memberNames,
      );

      if (result['success']) {
        await loadTripPayment(tripId);
      } else {
        _setError(result['error'] ?? 'Failed to create payment');
      }

      return result;
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> markAsPaid({
    required String paymentId,
    required String memberId,
    String? note,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _service.markMemberAsPaid(
        paymentId: paymentId,
        memberId: memberId,
        note: note,
      );

      if (result['success']) {
        if (_currentPayment != null) {
          await loadTripPayment(_currentPayment!.tripId);
        }
        return true;
      } else {
        _setError(result['error'] ?? 'Failed to mark as paid');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTripPayment(String tripId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentPayment = await _service.getTripPayment(tripId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'hasUnpaidTrips': false, 'unpaidCount': 0, 'totalUnpaid': 0.0};
    }

    try {
      final status = await _service.checkUserPaymentStatus(user.uid);

      if (status['hasUnpaidTrips']) {
        _unpaidTripDetails = await _service.getUserUnpaidTripDetails(user.uid);
      } else {
        _unpaidTripDetails = [];
      }

      notifyListeners();
      return status;
    } catch (e) {
      return {
        'hasUnpaidTrips': false,
        'unpaidCount': 0,
        'totalUnpaid': 0.0,
        'error': e.toString(),
      };
    }
  }

  Future<bool> raiseDispute({
    required String paymentId,
    required String reason,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _service.raisePaymentDispute(
        paymentId: paymentId,
        reason: reason,
      );

      if (result['success']) {
        if (_currentPayment != null) {
          await loadTripPayment(_currentPayment!.tripId);
        }
        return true;
      } else {
        _setError(result['error'] ?? 'Failed to raise dispute');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearData() {
    _currentPayment = null;
    _userPaymentRecord = null;
    _unpaidTripDetails = [];
    _errorMessage = null;
    notifyListeners();
  }
}
