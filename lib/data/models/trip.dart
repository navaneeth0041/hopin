import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String createdBy;
  final String creatorName;
  final String? creatorProfileUrl;
  final String currentLocation;
  final double? currentLat;
  final double? currentLng;
  final String destination;
  final double? destLat;
  final double? destLng;
  final DateTime departureTime;
  final DateTime? endTime;
  final int availableSeats;
  final int totalSeats;
  final String? note;
  final TripStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final List<String> joinedUsers;
  final Map<String, dynamic>? creatorDetails;

  Trip({
    required this.id,
    required this.createdBy,
    required this.creatorName,
    this.creatorProfileUrl,
    required this.currentLocation,
    this.currentLat,
    this.currentLng,
    required this.destination,
    this.destLat,
    this.destLng,
    required this.departureTime,
    this.endTime,
    required this.availableSeats,
    required this.totalSeats,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
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
      'currentLat': currentLat,
      'currentLng': currentLng,
      'destination': destination,
      'destLat': destLat,
      'destLng': destLng,
      'departureTime': Timestamp.fromDate(departureTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'note': note,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
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
      currentLat: map['currentLat']?.toDouble(),
      currentLng: map['currentLng']?.toDouble(),
      destination: map['destination'] ?? '',
      destLat: map['destLat']?.toDouble(),
      destLng: map['destLng']?.toDouble(),
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null 
          ? (map['endTime'] as Timestamp).toDate() 
          : null,
      availableSeats: map['availableSeats'] ?? 0,
      totalSeats: map['totalSeats'] ?? 0,
      note: map['note'],
      status: _statusFromString(map['status'] ?? 'active'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
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
    double? currentLat,
    double? currentLng,
    String? destination,
    double? destLat,
    double? destLng,
    DateTime? departureTime,
    DateTime? endTime,
    int? availableSeats,
    int? totalSeats,
    String? note,
    TripStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    List<String>? joinedUsers,
    Map<String, dynamic>? creatorDetails,
  }) {
    return Trip(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      creatorProfileUrl: creatorProfileUrl ?? this.creatorProfileUrl,
      currentLocation: currentLocation ?? this.currentLocation,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      destination: destination ?? this.destination,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      departureTime: departureTime ?? this.departureTime,
      endTime: endTime ?? this.endTime,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      joinedUsers: joinedUsers ?? this.joinedUsers,
      creatorDetails: creatorDetails ?? this.creatorDetails,
    );
  }
}

enum TripStatus { active, completed, cancelled, full }