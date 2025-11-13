import 'package:cloud_firestore/cloud_firestore.dart';

class PrivacySettings {
  final bool profileVisible;
  final bool showProfilePicture;
  final bool showGender;
  final bool showDateOfBirth;
  final bool showDepartment;
  final bool showYear;
  final bool showHostel;
  final bool showRoomNumber;
  final bool showHometown;
  final bool showBio;
  final DateTime? lastUpdated;

  PrivacySettings({
    this.profileVisible = true,
    this.showProfilePicture = true,
    this.showGender = true,
    this.showDateOfBirth = true,
    this.showDepartment = true,
    this.showYear = true,
    this.showHostel = true,
    this.showRoomNumber = true,
    this.showHometown = true,
    this.showBio = true,
    this.lastUpdated,
  });

  factory PrivacySettings.fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      profileVisible: map['profileVisible'] ?? true,
      showProfilePicture: map['showProfilePicture'] ?? true,
      showGender: map['showGender'] ?? true,
      showDateOfBirth: map['showDateOfBirth'] ?? true,
      showDepartment: map['showDepartment'] ?? true,
      showYear: map['showYear'] ?? true,
      showHostel: map['showHostel'] ?? true,
      showRoomNumber: map['showRoomNumber'] ?? true,
      showHometown: map['showHometown'] ?? true,
      showBio: map['showBio'] ?? true,
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileVisible': profileVisible,
      'showProfilePicture': showProfilePicture,
      'showGender': showGender,
      'showDateOfBirth': showDateOfBirth,
      'showDepartment': showDepartment,
      'showYear': showYear,
      'showHostel': showHostel,
      'showRoomNumber': showRoomNumber,
      'showHometown': showHometown,
      'showBio': showBio,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  PrivacySettings copyWith({
    bool? profileVisible,
    bool? showProfilePicture,
    bool? showGender,
    bool? showDateOfBirth,
    bool? showDepartment,
    bool? showYear,
    bool? showHostel,
    bool? showRoomNumber,
    bool? showHometown,
    bool? showBio,
    DateTime? lastUpdated,
  }) {
    return PrivacySettings(
      profileVisible: profileVisible ?? this.profileVisible,
      showProfilePicture: showProfilePicture ?? this.showProfilePicture,
      showGender: showGender ?? this.showGender,
      showDateOfBirth: showDateOfBirth ?? this.showDateOfBirth,
      showDepartment: showDepartment ?? this.showDepartment,
      showYear: showYear ?? this.showYear,
      showHostel: showHostel ?? this.showHostel,
      showRoomNumber: showRoomNumber ?? this.showRoomNumber,
      showHometown: showHometown ?? this.showHometown,
      showBio: showBio ?? this.showBio,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool shouldShowField(String fieldName) {
    if (!profileVisible) return false;

    switch (fieldName) {
      case 'profilePicture':
        return showProfilePicture;
      case 'gender':
        return showGender;
      case 'dateOfBirth':
        return showDateOfBirth;
      case 'department':
        return showDepartment;
      case 'year':
        return showYear;
      case 'hostel':
        return showHostel;
      case 'roomNumber':
        return showRoomNumber;
      case 'hometown':
        return showHometown;
      case 'bio':
        return showBio;
      default:
        return true; // Name, email, phone are always visible
    }
  }
}