import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, paid, disputed }

class TripPayment {
  final String id;
  final String tripId;
  final String creatorId;
  final double totalAmount;
  final DateTime completedAt;
  final Map<String, MemberPayment> memberPayments;
  final bool isFullyPaid;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;

  TripPayment({
    required this.id,
    required this.tripId,
    required this.creatorId,
    required this.totalAmount,
    required this.completedAt,
    required this.memberPayments,
    required this.isFullyPaid,
    required this.createdAt,
    this.lastUpdatedAt,
  });

  double get perPersonShare => memberPayments.isEmpty 
      ? 0 
      : totalAmount / (memberPayments.length + 1);

  int get paidCount => memberPayments.values
      .where((payment) => payment.status == PaymentStatus.paid)
      .length;

  int get pendingCount => memberPayments.values
      .where((payment) => payment.status == PaymentStatus.pending)
      .length;

  factory TripPayment.fromMap(Map<String, dynamic> map) {
    final memberPaymentsMap = <String, MemberPayment>{};
    final paymentsData = map['memberPayments'] as Map<String, dynamic>? ?? {};
    
    paymentsData.forEach((userId, data) {
      memberPaymentsMap[userId] = MemberPayment.fromMap(
        data as Map<String, dynamic>,
      );
    });

    return TripPayment(
      id: map['id'] ?? '',
      tripId: map['tripId'] ?? '',
      creatorId: map['creatorId'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      completedAt: _parseDateTime(map['completedAt']),
      memberPayments: memberPaymentsMap,
      isFullyPaid: map['isFullyPaid'] ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      lastUpdatedAt: map['lastUpdatedAt'] != null 
          ? _parseDateTime(map['lastUpdatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final memberPaymentsMap = <String, dynamic>{};
    memberPayments.forEach((userId, payment) {
      memberPaymentsMap[userId] = payment.toMap();
    });

    return {
      'id': id,
      'tripId': tripId,
      'creatorId': creatorId,
      'totalAmount': totalAmount,
      'completedAt': Timestamp.fromDate(completedAt),
      'memberPayments': memberPaymentsMap,
      'isFullyPaid': isFullyPaid,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': lastUpdatedAt != null
          ? Timestamp.fromDate(lastUpdatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  TripPayment copyWith({
    String? id,
    String? tripId,
    String? creatorId,
    double? totalAmount,
    DateTime? completedAt,
    Map<String, MemberPayment>? memberPayments,
    bool? isFullyPaid,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return TripPayment(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      creatorId: creatorId ?? this.creatorId,
      totalAmount: totalAmount ?? this.totalAmount,
      completedAt: completedAt ?? this.completedAt,
      memberPayments: memberPayments ?? this.memberPayments,
      isFullyPaid: isFullyPaid ?? this.isFullyPaid,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

class MemberPayment {
  final String userId;
  final String userName;
  final double amountDue;
  final PaymentStatus status;
  final DateTime? paidAt;
  final DateTime? markedPaidBy;
  final String? note;

  MemberPayment({
    required this.userId,
    required this.userName,
    required this.amountDue,
    required this.status,
    this.paidAt,
    this.markedPaidBy,
    this.note,
  });

  factory MemberPayment.fromMap(Map<String, dynamic> map) {
    return MemberPayment(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      amountDue: (map['amountDue'] ?? 0).toDouble(),
      status: _statusFromString(map['status'] ?? 'pending'),
      paidAt: map['paidAt'] != null ? _parseDateTime(map['paidAt']) : null,
      markedPaidBy: map['markedPaidBy'] != null 
          ? _parseDateTime(map['markedPaidBy']) 
          : null,
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'amountDue': amountDue,
      'status': _statusToString(status),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'markedPaidBy': markedPaidBy != null
          ? Timestamp.fromDate(markedPaidBy!)
          : null,
      'note': note,
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static PaymentStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'disputed':
        return PaymentStatus.disputed;
      default:
        return PaymentStatus.pending;
    }
  }

  static String _statusToString(PaymentStatus status) {
    return status.toString().split('.').last;
  }

  MemberPayment copyWith({
    String? userId,
    String? userName,
    double? amountDue,
    PaymentStatus? status,
    DateTime? paidAt,
    DateTime? markedPaidBy,
    String? note,
  }) {
    return MemberPayment(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      amountDue: amountDue ?? this.amountDue,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      markedPaidBy: markedPaidBy ?? this.markedPaidBy,
      note: note ?? this.note,
    );
  }
}

class UserPaymentRecord {
  final String userId;
  final List<String> unpaidTripIds;
  final double totalUnpaidAmount;
  final DateTime? lastUpdated;

  UserPaymentRecord({
    required this.userId,
    required this.unpaidTripIds,
    required this.totalUnpaidAmount,
    this.lastUpdated,
  });

  bool get hasUnpaidTrips => unpaidTripIds.isNotEmpty;

  factory UserPaymentRecord.fromMap(Map<String, dynamic> map) {
    return UserPaymentRecord(
      userId: map['userId'] ?? '',
      unpaidTripIds: List<String>.from(map['unpaidTripIds'] ?? []),
      totalUnpaidAmount: (map['totalUnpaidAmount'] ?? 0).toDouble(),
      lastUpdated: map['lastUpdated'] != null
          ? _parseDateTime(map['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'unpaidTripIds': unpaidTripIds,
      'totalUnpaidAmount': totalUnpaidAmount,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}