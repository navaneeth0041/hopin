import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailVerified = false;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _isEmailVerified;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _isEmailVerified = user?.emailVerified ?? false;
      if (user != null) {
        _loadUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      _userData = await _authService.getUserData(_user!.uid);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String phoneNumber,
    required String emergencyName,
    required String emergencyPhone,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signUpWithEmailPassword(
      email: email,
      password: password,
      userData: {
        'fullName': fullName,
        'email': email,
        'studentId': studentId,
        'phoneNumber': phoneNumber,
        'emergencyName': emergencyName,
        'emergencyPhone': emergencyPhone,
      },
    );

    if (!result['success']) {
      _setError(result['error']);
    }

    _setLoading(false);
    return result;
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.signInWithEmailPassword(
      email: email,
      password: password,
    );

    if (!result['success']) {
      _setError(result['error']);
    }

    _setLoading(false);
    return result;
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.sendPasswordResetEmail(email);

    if (!result['success']) {
      _setError(result['error']);
    }

    _setLoading(false);
    return result;
  }

  Future<Map<String, dynamic>> sendEmailVerification() async {
    final result = await _authService.sendEmailVerification();
    return result;
  }

  Future<bool> checkEmailVerified() async {
    final isVerified = await _authService.checkEmailVerified();
    _isEmailVerified = isVerified;
    notifyListeners();
    return isVerified;
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _user = null;
    _userData = null;
    _isEmailVerified = false;
    _setLoading(false);
  }

  Future<bool> updateUserData(Map<String, dynamic> data) async {
    if (_user != null) {
      final success = await _authService.updateUserData(_user!.uid, data);
      if (success) {
        await _loadUserData();
      }
      return success;
    }
    return false;
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
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
