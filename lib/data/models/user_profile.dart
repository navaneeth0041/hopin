class UserProfile {
  final String name;
  final String email;
  final String studentId;
  final String phone;
  final String? department;
  final String? yearOfStudy;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? profileImagePath;

  UserProfile({
    required this.name,
    required this.email,
    required this.studentId,
    required this.phone,
    this.department,
    this.yearOfStudy,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.profileImagePath,
  });

  // Calculate profile completion percentage
  int get completionPercentage {
    int completedFields = 0;
    const int totalFields = 9;

    if (name.isNotEmpty) completedFields++;
    if (email.isNotEmpty) completedFields++;
    if (studentId.isNotEmpty) completedFields++;
    if (phone.isNotEmpty) completedFields++;
    if (department != null && department!.isNotEmpty) completedFields++;
    if (yearOfStudy != null && yearOfStudy!.isNotEmpty) completedFields++;
    if (emergencyContactName.isNotEmpty) completedFields++;
    if (emergencyContactPhone.isNotEmpty) completedFields++;
    if (emergencyContactRelation != null && emergencyContactRelation!.isNotEmpty) completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  // Copy with method for updating profile
  UserProfile copyWith({
    String? name,
    String? email,
    String? studentId,
    String? phone,
    String? department,
    String? yearOfStudy,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? profileImagePath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'studentId': studentId,
      'phone': phone,
      'department': department,
      'yearOfStudy': yearOfStudy,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'emergencyContactRelation': emergencyContactRelation,
      'profileImagePath': profileImagePath,
    };
  }

  // Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      studentId: json['studentId'] ?? '',
      phone: json['phone'] ?? '',
      department: json['department'],
      yearOfStudy: json['yearOfStudy'],
      emergencyContactName: json['emergencyContactName'] ?? '',
      emergencyContactPhone: json['emergencyContactPhone'] ?? '',
      emergencyContactRelation: json['emergencyContactRelation'],
      profileImagePath: json['profileImagePath'],
    );
  }

  factory UserProfile.empty() {
    return UserProfile(
      name: '',
      email: '',
      studentId: '',
      phone: '',
      emergencyContactName: '',
      emergencyContactPhone: '',
    );
  }
}