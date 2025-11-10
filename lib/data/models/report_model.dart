import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus { submitted, underReview, resolved, closed }

enum ReportCategory {
  safetyConcern,
  driverIssue,
  vehicleProblem,
  paymentDispute,
  routeProblem,
  other,
}

class Report {
  final String id;
  final String userId;
  final ReportCategory category;
  final String description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final String? tripId;
  final String? driverId;
  final String? adminResponse;
  final List<String> imageUrls;

  Report({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.tripId,
    this.driverId,
    this.adminResponse,
    this.imageUrls = const [],
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      category: _categoryFromString(map['category'] ?? 'other'),
      description: map['description'] ?? '',
      status: _statusFromString(map['status'] ?? 'submitted'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      resolvedAt: map['resolvedAt'] != null
          ? (map['resolvedAt'] as Timestamp).toDate()
          : null,
      tripId: map['tripId'],
      driverId: map['driverId'],
      adminResponse: map['adminResponse'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': _categoryToString(category),
      'description': description,
      'status': statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'tripId': tripId,
      'driverId': driverId,
      'adminResponse': adminResponse,
      'imageUrls': imageUrls,
    };
  }

  Report copyWith({
    String? id,
    String? userId,
    ReportCategory? category,
    String? description,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? tripId,
    String? driverId,
    String? adminResponse,
    List<String>? imageUrls,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      tripId: tripId ?? this.tripId,
      driverId: driverId ?? this.driverId,
      adminResponse: adminResponse ?? this.adminResponse,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  static ReportCategory _categoryFromString(String category) {
    switch (category) {
      case 'safetyConcern':
        return ReportCategory.safetyConcern;
      case 'driverIssue':
        return ReportCategory.driverIssue;
      case 'vehicleProblem':
        return ReportCategory.vehicleProblem;
      case 'paymentDispute':
        return ReportCategory.paymentDispute;
      case 'routeProblem':
        return ReportCategory.routeProblem;
      default:
        return ReportCategory.other;
    }
  }

  static String _categoryToString(ReportCategory category) {
    return category.toString().split('.').last;
  }

  static ReportStatus _statusFromString(String status) {
    switch (status) {
      case 'submitted':
        return ReportStatus.submitted;
      case 'underReview':
        return ReportStatus.underReview;
      case 'resolved':
        return ReportStatus.resolved;
      case 'closed':
        return ReportStatus.closed;
      default:
        return ReportStatus.submitted;
    }
  }

  static String statusToString(ReportStatus status) {
    return status.toString().split('.').last;
  }

  String get categoryDisplayName {
    switch (category) {
      case ReportCategory.safetyConcern:
        return 'Safety Concern';
      case ReportCategory.driverIssue:
        return 'Driver Issue';
      case ReportCategory.vehicleProblem:
        return 'Vehicle Problem';
      case ReportCategory.paymentDispute:
        return 'Payment Dispute';
      case ReportCategory.routeProblem:
        return 'Route Problem';
      case ReportCategory.other:
        return 'Other';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.closed:
        return 'Closed';
    }
  }
}

class SupportTicket {
  final String id;
  final String userId;
  final String email;
  final String subject;
  final String description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final String? adminResponse;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.email,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.adminResponse,
  });

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      subject: map['subject'] ?? 'General Support',
      description: map['description'] ?? '',
      status: Report._statusFromString(map['status'] ?? 'submitted'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      resolvedAt: map['resolvedAt'] != null
          ? (map['resolvedAt'] as Timestamp).toDate()
          : null,
      adminResponse: map['adminResponse'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'subject': subject,
      'description': description,
      'status': Report.statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'adminResponse': adminResponse,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.closed:
        return 'Closed';
    }
  }
}
