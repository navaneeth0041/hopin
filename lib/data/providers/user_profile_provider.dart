import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopin/data/services/image_cache_service.dart';
import 'package:hopin/data/services/user_service.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final ImageCacheService _imageCache = ImageCacheService();

  UserProfile _userProfile = UserProfile(
    name: '',
    email: '',
    phone: '',
    studentId: '',
  );

  bool _isLoading = false;
  String? _errorMessage;

  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get completionPercentage {
    int score = 0;

    if (_userProfile.name.isNotEmpty) score += 10;
    if (_userProfile.email.isNotEmpty) score += 10;
    if (_userProfile.phone.isNotEmpty) score += 10;
    if (_userProfile.studentId.isNotEmpty) score += 10;

    if (_userProfile.profileImageBase64 != null ||
        _userProfile.profileImagePath != null) {
      score += 8;
    }
    if (_userProfile.gender != null && _userProfile.gender!.isNotEmpty) {
      score += 8;
    }
    if (_userProfile.dateOfBirth != null &&
        _userProfile.dateOfBirth!.isNotEmpty) {
      score += 7;
    }
    if (_userProfile.department != null &&
        _userProfile.department!.isNotEmpty) {
      score += 7;
    }
    if (_userProfile.year != null && _userProfile.year!.isNotEmpty) {
      score += 8;
    }
    if (_userProfile.hostel != null && _userProfile.hostel!.isNotEmpty) {
      score += 7;
    }
    if (_userProfile.roomNumber != null &&
        _userProfile.roomNumber!.isNotEmpty) {
      score += 7;
    }
    if (_userProfile.hometown != null && _userProfile.hometown!.isNotEmpty) {
      score += 8;
    }
    if (_userProfile.bio != null && _userProfile.bio!.isNotEmpty) {
      score += 8;
    }

    return score.clamp(0, 100);
  }

  Future<void> loadUserProfile(String uid) async {
    _setLoading(true);
    _clearError();

    try {
      final userData = await _userService.getUserProfile(uid);

      if (userData != null) {
        _userProfile = UserProfile.fromMap(userData);
      }
    } catch (e) {
      _setError('Failed to load profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(
    Map<String, dynamic> updates, {
    File? profileImage,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _setError('User not authenticated');
        return false;
      }

      final success = await _userService.updateUserProfile(
        uid,
        updates,
        profileImage: profileImage,
      );

      if (success) {
        await loadUserProfile(uid);
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('Error updating profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _imageCache.clearUserCache(uid);
    }
    _userProfile = UserProfile(name: '', email: '', phone: '', studentId: '');
    notifyListeners();
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
}