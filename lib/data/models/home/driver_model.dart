class Driver {
  final String id;
  final String name;
  final String phoneNumber;
  final String vehicleType;
  final String vehicleNumber;
  final String area;
  final double rating;
  final bool isVerified;
  final String? profileImage;

  Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.area,
    required this.rating,
    this.isVerified = true,
    this.profileImage,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      vehicleType: json['vehicleType'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      area: json['area'] as String,
      rating: (json['rating'] as num).toDouble(),
      isVerified: json['isVerified'] as bool? ?? true,
      profileImage: json['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'area': area,
      'rating': rating,
      'isVerified': isVerified,
      'profileImage': profileImage,
    };
  }
}
