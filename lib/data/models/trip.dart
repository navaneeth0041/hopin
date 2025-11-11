import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String createdBy;
  final String creatorName;
  final String? creatorProfileUrl;
  final String currentLocation;
  final String destination;
  final DateTime departureTime;
  final int availableSeats;
  final int totalSeats;
  final String? note;
  final TripStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> joinedUsers;
  final Map<String, dynamic>? creatorDetails;

  Trip({
    required this.id,
    required this.createdBy,
    required this.creatorName,
    this.creatorProfileUrl,
    required this.currentLocation,
    required this.destination,
    required this.departureTime,
    required this.availableSeats,
    required this.totalSeats,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.joinedUsers = const [],
    this.creatorDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdBy': createdBy,
      'creatorName': creatorName,
      'creatorProfileUrl': creatorProfileUrl,
      'currentLocation': currentLocation,
      'destination': destination,
      'departureTime': Timestamp.fromDate(departureTime),
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'note': note,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'joinedUsers': joinedUsers,
      'creatorDetails': creatorDetails,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map, String documentId) {
    return Trip(
      id: documentId,
      createdBy: map['createdBy'] ?? '',
      creatorName: map['creatorName'] ?? '',
      creatorProfileUrl: map['creatorProfileUrl'],
      currentLocation: map['currentLocation'] ?? '',
      destination: map['destination'] ?? '',
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      availableSeats: map['availableSeats'] ?? 0,
      totalSeats: map['totalSeats'] ?? 0,
      note: map['note'],
      status: _statusFromString(map['status'] ?? 'active'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      joinedUsers: List<String>.from(map['joinedUsers'] ?? []),
      creatorDetails: map['creatorDetails'],
    );
  }

  static TripStatus _statusFromString(String status) {
    switch (status) {
      case 'active':
        return TripStatus.active;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      case 'full':
        return TripStatus.full;
      default:
        return TripStatus.active;
    }
  }

  Trip copyWith({
    String? id,
    String? createdBy,
    String? creatorName,
    String? creatorProfileUrl,
    String? currentLocation,
    String? destination,
    DateTime? departureTime,
    int? availableSeats,
    int? totalSeats,
    String? note,
    TripStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? joinedUsers,
    Map<String, dynamic>? creatorDetails,
  }) {
    return Trip(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      creatorProfileUrl: creatorProfileUrl ?? this.creatorProfileUrl,
      currentLocation: currentLocation ?? this.currentLocation,
      destination: destination ?? this.destination,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      joinedUsers: joinedUsers ?? this.joinedUsers,
      creatorDetails: creatorDetails ?? this.creatorDetails,
    );
  }
}

enum TripStatus { active, completed, cancelled, full }
