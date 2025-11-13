import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopin/data/models/privacy_settings_model.dart';
import 'package:hopin/data/services/privacy_service.dart';

class PrivacyProvider extends ChangeNotifier {
  final PrivacyService _service = PrivacyService();

  PrivacySettings _settings = PrivacySettings();
  PrivacySettings _originalSettings = PrivacySettings();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  PrivacySettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  bool get hasUnsavedChanges {
    return _settings.profileVisible != _originalSettings.profileVisible ||
        _settings.showProfilePicture != _originalSettings.showProfilePicture ||
        _settings.showGender != _originalSettings.showGender ||
        _settings.showDateOfBirth != _originalSettings.showDateOfBirth ||
        _settings.showDepartment != _originalSettings.showDepartment ||
        _settings.showYear != _originalSettings.showYear ||
        _settings.showHostel != _originalSettings.showHostel ||
        _settings.showRoomNumber != _originalSettings.showRoomNumber ||
        _settings.showHometown != _originalSettings.showHometown ||
        _settings.showBio != _originalSettings.showBio;
  }

  Future<void> loadPrivacySettings() async {
    _setLoading(true);
    _clearError();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _setError('User not authenticated');
        return;
      }

      _settings = await _service.getPrivacySettings(uid);
      _originalSettings = _settings.copyWith();
    } catch (e) {
      _setError('Failed to load privacy settings: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> savePrivacySettings() async {
    _setSaving(true);
    _clearError();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _setError('User not authenticated');
        return false;
      }

      final success = await _service.updatePrivacySettings(uid, _settings);
      if (success) {
        _originalSettings = _settings.copyWith();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to save privacy settings: ${e.toString()}');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void updateProfileVisibility(bool value) {
    _settings = _settings.copyWith(profileVisible: value);
    notifyListeners();
  }

  void updateShowProfilePicture(bool value) {
    _settings = _settings.copyWith(showProfilePicture: value);
    notifyListeners();
  }

  void updateShowGender(bool value) {
    _settings = _settings.copyWith(showGender: value);
    notifyListeners();
  }

  void updateShowDateOfBirth(bool value) {
    _settings = _settings.copyWith(showDateOfBirth: value);
    notifyListeners();
  }

  void updateShowDepartment(bool value) {
    _settings = _settings.copyWith(showDepartment: value);
    notifyListeners();
  }

  void updateShowYear(bool value) {
    _settings = _settings.copyWith(showYear: value);
    notifyListeners();
  }

  void updateShowHostel(bool value) {
    _settings = _settings.copyWith(showHostel: value);
    notifyListeners();
  }

  void updateShowRoomNumber(bool value) {
    _settings = _settings.copyWith(showRoomNumber: value);
    notifyListeners();
  }

  void updateShowHometown(bool value) {
    _settings = _settings.copyWith(showHometown: value);
    notifyListeners();
  }

  void updateShowBio(bool value) {
    _settings = _settings.copyWith(showBio: value);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
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