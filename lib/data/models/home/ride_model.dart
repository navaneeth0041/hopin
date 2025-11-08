class RideModel {
  final String id;
  final String driverId;
  final String driverName;
  final String hostel;
  final String time;
  final int availableSeats;
  final String price;
  final String from;
  final String to;
  final String date;
  final String vehicleType;
  final String phoneNumber;
  final String note;
  final String status; 
  final DateTime createdAt;

  RideModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.hostel,
    required this.time,
    required this.availableSeats,
    required this.price,
    required this.from,
    required this.to,
    required this.date,
    required this.vehicleType,
    required this.phoneNumber,
    this.note = '',
    this.status = 'active',
    required this.createdAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] ?? '',
      driverId: json['driver_id'] ?? '',
      driverName: json['driver_name'] ?? '',
      hostel: json['hostel'] ?? '',
      time: json['time'] ?? '',
      availableSeats: json['available_seats'] ?? 0,
      price: json['price'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      date: json['date'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      note: json['note'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'driver_name': driverName,
      'hostel': hostel,
      'time': time,
      'available_seats': availableSeats,
      'price': price,
      'from': from,
      'to': to,
      'date': date,
      'vehicle_type': vehicleType,
      'phone_number': phoneNumber,
      'note': note,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RideModel copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? hostel,
    String? time,
    int? availableSeats,
    String? price,
    String? from,
    String? to,
    String? date,
    String? vehicleType,
    String? phoneNumber,
    String? note,
    String? status,
    DateTime? createdAt,
  }) {
    return RideModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      hostel: hostel ?? this.hostel,
      time: time ?? this.time,
      availableSeats: availableSeats ?? this.availableSeats,
      price: price ?? this.price,
      from: from ?? this.from,
      to: to ?? this.to,
      date: date ?? this.date,
      vehicleType: vehicleType ?? this.vehicleType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'RideModel(id: $id, driverName: $driverName, from: $from, to: $to, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RideModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

extension RideModelMockData on RideModel {
  static List<RideModel> getMockRides() {
    return [
      RideModel(
        id: '1',
        driverId: 'user_1',
        driverName: 'Rahul Kumar',
        hostel: 'Hostel A',
        time: '4:30 PM',
        availableSeats: 3,
        price: '₹50',
        from: 'College Main Gate',
        to: 'City Mall',
        date: '8 Nov 2025',
        vehicleType: 'Sedan',
        phoneNumber: '+91 98765 43210',
        note: 'Please be on time. Will wait for 5 minutes only.',
        createdAt: DateTime.now(),
      ),
      RideModel(
        id: '2',
        driverId: 'user_2',
        driverName: 'Priya Sharma',
        hostel: 'Girls Hostel 1',
        time: '5:00 PM',
        availableSeats: 2,
        price: '₹60',
        from: 'Library Block',
        to: 'Central Station',
        date: '8 Nov 2025',
        vehicleType: 'Hatchback',
        phoneNumber: '+91 98765 43211',
        note: 'AC car. Music preferences welcome.',
        createdAt: DateTime.now(),
      ),
      RideModel(
        id: '3',
        driverId: 'user_3',
        driverName: 'Amit Patel',
        hostel: 'Hostel B',
        time: '5:30 PM',
        availableSeats: 4,
        price: '₹45',
        from: 'Sports Complex',
        to: 'Tech Park',
        date: '8 Nov 2025',
        vehicleType: 'SUV',
        phoneNumber: '+91 98765 43212',
        note: 'Spacious vehicle. Can accommodate luggage.',
        createdAt: DateTime.now(),
      ),
      RideModel(
        id: '4',
        driverId: 'user_4',
        driverName: 'Sneha Reddy',
        hostel: 'Hostel C',
        time: '6:00 PM',
        availableSeats: 1,
        price: '₹55',
        from: 'Admin Block',
        to: 'Airport',
        date: '8 Nov 2025',
        vehicleType: 'Sedan',
        phoneNumber: '+91 98765 43213',
        note: 'Going to airport. Can help with heavy bags.',
        createdAt: DateTime.now(),
      ),
    ];
  }
}