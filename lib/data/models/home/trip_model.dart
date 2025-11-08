// lib/features/home/models/trip_model.dart

enum TripStatus {
  waiting,
  confirmed,
  inProgress,
}

class TripModel {
  final String id;
  final String destination;
  final String date;
  final String time;
  final String participants;
  final String fareShare;
  final TripStatus status;

  TripModel({
    required this.id,
    required this.destination,
    required this.date,
    required this.time,
    required this.participants,
    required this.fareShare,
    required this.status,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      destination: json['destination'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      participants: json['participants'] as String,
      fareShare: json['fareShare'] as String,
      status: TripStatus.values.firstWhere(
        (status) => status.name == json['status'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'date': date,
      'time': time,
      'participants': participants,
      'fareShare': fareShare,
      'status': status.name,
    };
  }
}