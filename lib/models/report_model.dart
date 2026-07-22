import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String type; // 'food' or 'user'
  final String reason;
  final String description;
  final String targetId; // food postId or user uid
  final String reporterId;
  final String? imageUrl;
  final String status; // 'Pending' or 'Resolved'
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.type,
    required this.reason,
    required this.description,
    required this.targetId,
    required this.reporterId,
    this.imageUrl,
    this.status = 'Pending',
    required this.createdAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      type: map['type'] ?? 'food',
      reason: map['reason'] ?? '',
      description: map['description'] ?? '',
      targetId: map['targetId'] ?? '',
      reporterId: map['reporterId'] ?? '',
      imageUrl: map['imageUrl'],
      status: map['status'] ?? 'Pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'reason': reason,
      'description': description,
      'targetId': targetId,
      'reporterId': reporterId,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
