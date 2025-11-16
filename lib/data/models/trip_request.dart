import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, rejected, cancelled }

class TripRequest {
  final String id;
  final String tripId;
  final String requesterId;
  final String requesterName;
  final String? requesterPhone;
  final String? requesterProfileImage;
  final String? message;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? responseMessage;

  TripRequest({
    required this.id,
    required this.tripId,
    required this.requesterId,
    required this.requesterName,
    this.requesterPhone,
    this.requesterProfileImage,
    this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.responseMessage,
  });

  factory TripRequest.fromMap(Map<String, dynamic> map, String documentId) {
    return TripRequest(
      id: documentId,
      tripId: map['tripId'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterPhone: map['requesterPhone'],
      requesterProfileImage: map['requesterProfileImage'],
      message: map['message'],
      status: _statusFromString(map['status'] ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      respondedAt: map['respondedAt'] != null
          ? (map['respondedAt'] as Timestamp).toDate()
          : null,
      responseMessage: map['responseMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'requesterProfileImage': requesterProfileImage,
      'message': message,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null
          ? Timestamp.fromDate(respondedAt!)
          : null,
      'responseMessage': responseMessage,
    };
  }

  static RequestStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.pending;
    }
  }

  TripRequest copyWith({
    String? id,
    String? tripId,
    String? requesterId,
    String? requesterName,
    String? requesterPhone,
    String? requesterProfileImage,
    String? message,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? responseMessage,
  }) {
    return TripRequest(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      requesterProfileImage:
          requesterProfileImage ?? this.requesterProfileImage,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      responseMessage: responseMessage ?? this.responseMessage,
    );
  }
}

enum NotificationType {
  tripRequest,
  requestAccepted,
  requestRejected,
  tripCancelled,
  memberLeft,
  memberJoined,
  tripStartingSoon,
  tripCompleted,
}

class TripNotification {
  final String id;
  final String userId;
  final String tripId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  TripNotification({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory TripNotification.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TripNotification(
      id: documentId,
      userId: map['userId'] ?? '',
      tripId: map['tripId'] ?? '',
      type: _typeFromString(map['type'] ?? 'tripRequest'),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      data: map['data'],
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tripId': tripId,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static NotificationType _typeFromString(String type) {
    switch (type) {
      case 'tripRequest':
        return NotificationType.tripRequest;
      case 'requestAccepted':
        return NotificationType.requestAccepted;
      case 'requestRejected':
        return NotificationType.requestRejected;
      case 'tripCancelled':
        return NotificationType.tripCancelled;
      case 'memberLeft':
        return NotificationType.memberLeft;
      case 'memberJoined':
        return NotificationType.memberJoined;
      case 'tripStartingSoon':
        return NotificationType.tripStartingSoon;
      case 'tripCompleted':
        return NotificationType.tripCompleted;
      default:
        return NotificationType.tripRequest;
    }
  }

  TripNotification copyWith({
    String? id,
    String? userId,
    String? tripId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return TripNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
