import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUser {
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? department;
  final String? year;
  final String? phone;
  final DateTime? blockedAt;

  BlockedUser({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.department,
    this.year,
    this.phone,
    this.blockedAt,
  });

  factory BlockedUser.fromMap(Map<String, dynamic> map) {
    final details = map['details'] as Map<String, dynamic>?;

    return BlockedUser(
      uid: map['uid'] ?? '',
      name: details?['fullName'] ?? map['name'] ?? '',
      email: details?['email'] ?? map['email'] ?? '',
      profileImageUrl: details?['profileImageUrl'] ?? map['profileImageUrl'],
      department: details?['department'] ?? map['department'],
      year: details?['year'] ?? map['year'],
      phone: details?['phoneNumber'] ?? map['phone'],
      blockedAt: map['blockedAt'] != null
          ? (map['blockedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'department': department,
      'year': year,
      'phone': phone,
      'blockedAt': blockedAt != null
          ? Timestamp.fromDate(blockedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  BlockedUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    String? department,
    String? year,
    String? phone,
    DateTime? blockedAt,
  }) {
    return BlockedUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      department: department ?? this.department,
      year: year ?? this.year,
      phone: phone ?? this.phone,
      blockedAt: blockedAt ?? this.blockedAt,
    );
  }
}
