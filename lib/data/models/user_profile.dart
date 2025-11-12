class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String studentId;
  final String? profileImagePath;
  final String? profileImageBase64;

  final String? gender;
  final String? dateOfBirth;
  final String? department;
  final String? year;
  final String? hostel;
  final String? roomNumber;
  final String? hometown;
  final String? bio;

  final DateTime? createdAt;
  final DateTime? lastUpdated;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.studentId,
    this.profileImagePath,
    this.profileImageBase64,
    this.gender,
    this.dateOfBirth,
    this.department,
    this.year,
    this.hostel,
    this.roomNumber,
    this.hometown,
    this.bio,
    this.createdAt,
    this.lastUpdated,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final details = map['details'] as Map<String, dynamic>? ?? {};

    return UserProfile(
      name: details['fullName'] ?? '',
      email: details['email'] ?? '',
      phone: details['phoneNumber'] ?? '',
      studentId: details['studentId'] ?? '',
      profileImagePath: details['profileImagePath'],
      profileImageBase64: details['profileImageBase64'],
      gender: details['gender'],
      dateOfBirth: details['dateOfBirth'],
      department: details['department'],
      year: details['year'],
      hostel: details['hostel'],
      roomNumber: details['roomNumber'],
      hometown: details['hometown'],
      bio: details['bio'],
      createdAt: details['createdAt'] != null
          ? (details['createdAt'] as dynamic).toDate()
          : null,
      lastUpdated: details['lastUpdated'] != null
          ? (details['lastUpdated'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'details': {
        'fullName': name,
        'email': email,
        'phoneNumber': phone,
        'studentId': studentId,
        'profileImagePath': profileImagePath,
        'profileImageBase64': profileImageBase64,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'department': department,
        'year': year,
        'hostel': hostel,
        'roomNumber': roomNumber,
        'hometown': hometown,
        'bio': bio,
      },
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? studentId,
    String? profileImagePath,
    String? profileImageBase64,
    String? gender,
    String? dateOfBirth,
    String? department,
    String? year,
    String? hostel,
    String? roomNumber,
    String? hometown,
    String? bio,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      studentId: studentId ?? this.studentId,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      department: department ?? this.department,
      year: year ?? this.year,
      hostel: hostel ?? this.hostel,
      roomNumber: roomNumber ?? this.roomNumber,
      hometown: hometown ?? this.hometown,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
