// lib/features/home/models/nearby_trip_model.dart

class NearbyTripModel {
  final String id;
  final String creatorName;
  final double creatorRating;
  final String destination;
  final String departureTime;
  final String availableSeats;
  final String farePerPerson;
  final int matchPercentage;
  final String distance;
  final String routeImage;

  NearbyTripModel({
    required this.id,
    required this.creatorName,
    required this.creatorRating,
    required this.destination,
    required this.departureTime,
    required this.availableSeats,
    required this.farePerPerson,
    required this.matchPercentage,
    required this.distance,
    required this.routeImage,
  });

  factory NearbyTripModel.fromJson(Map<String, dynamic> json) {
    return NearbyTripModel(
      id: json['id'] as String,
      creatorName: json['creatorName'] as String,
      creatorRating: (json['creatorRating'] as num).toDouble(),
      destination: json['destination'] as String,
      departureTime: json['departureTime'] as String,
      availableSeats: json['availableSeats'] as String,
      farePerPerson: json['farePerPerson'] as String,
      matchPercentage: json['matchPercentage'] as int,
      distance: json['distance'] as String,
      routeImage: json['routeImage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorName': creatorName,
      'creatorRating': creatorRating,
      'destination': destination,
      'departureTime': departureTime,
      'availableSeats': availableSeats,
      'farePerPerson': farePerPerson,
      'matchPercentage': matchPercentage,
      'distance': distance,
      'routeImage': routeImage,
    };
  }
}