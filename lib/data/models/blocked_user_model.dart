import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hopin/data/models/privacy_settings_model.dart';

class BlockedUser {
  final String uid;
  final String name;
  final String email;
  final String? profileImageBase64;
  final String? department;
  final String? year;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? hostel;
  final String? roomNumber;
  final String? hometown;
  final String? bio;
  final DateTime? blockedAt;
  final PrivacySettings? privacySettings;

  BlockedUser({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageBase64,
    this.department,
    this.year,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.hostel,
    this.roomNumber,
    this.hometown,
    this.bio,
    this.blockedAt,
    this.privacySettings,
  });

  factory BlockedUser.fromMap(Map<String, dynamic> map,
      {PrivacySettings? privacy}) {
    final details = map['details'] as Map<String, dynamic>?;

    return BlockedUser(
      uid: map['uid'] ?? '',
      name: details?['fullName'] ?? map['name'] ?? '',
      email: details?['email'] ?? map['email'] ?? '',
      profileImageBase64: details?['profileImageBase64'] ?? map['profileImageBase64'],
      department: details?['department'] ?? map['department'],
      year: details?['year'] ?? map['year'],
      phone: details?['phoneNumber'] ?? map['phone'],
      gender: details?['gender'] ?? map['gender'],
      dateOfBirth: details?['dateOfBirth'] ?? map['dateOfBirth'],
      hostel: details?['hostel'] ?? map['hostel'],
      roomNumber: details?['roomNumber'] ?? map['roomNumber'],
      hometown: details?['hometown'] ?? map['hometown'],
      bio: details?['bio'] ?? map['bio'],
      blockedAt: map['blockedAt'] != null
          ? (map['blockedAt'] as Timestamp).toDate()
          : null,
      privacySettings: privacy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImageBase64': profileImageBase64,
      'department': department,
      'year': year,
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'hostel': hostel,
      'roomNumber': roomNumber,
      'hometown': hometown,
      'bio': bio,
      'blockedAt': blockedAt != null
          ? Timestamp.fromDate(blockedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  BlockedUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageBase64,
    String? department,
    String? year,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? hostel,
    String? roomNumber,
    String? hometown,
    String? bio,
    DateTime? blockedAt,
    PrivacySettings? privacySettings,
  }) {
    return BlockedUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      department: department ?? this.department,
      year: year ?? this.year,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hostel: hostel ?? this.hostel,
      roomNumber: roomNumber ?? this.roomNumber,
      hometown: hometown ?? this.hometown,
      bio: bio ?? this.bio,
      blockedAt: blockedAt ?? this.blockedAt,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }
}