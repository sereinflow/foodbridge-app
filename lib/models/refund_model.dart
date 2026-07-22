import 'package:cloud_firestore/cloud_firestore.dart';

class RefundModel {
  final String refundId;
  final String orderId;
  final double amount;
  final String status;
  final String reason;
  final DateTime createdAt;

  RefundModel({
    required this.refundId,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.reason,
    required this.createdAt,
  });

  factory RefundModel.fromMap(Map<String, dynamic> map, String id) {
    return RefundModel(
      refundId: id,
      orderId: map['orderId'] ?? '',
      amount: map['amount'] is num ? (map['amount'] as num).toDouble() : 0.0,
      status: map['status'] ?? '',
      reason: map['reason'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'amount': amount,
      'status': status,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
