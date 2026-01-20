import 'package:cloud_firestore/cloud_firestore.dart';

class FoodRequestModel {
  final String id;
  final String postId;
  final String donorId;
  final String requesterId;
  final String requesterName;
  final String requesterNumber;
  final String requesterAddress;
  final String status; // Pending, Approved, Rejected, Completed
  final DateTime createdAt;
  final String postTitle;
  final String postImageUrl;
  final String postType; // Free or Sale

  FoodRequestModel({
    required this.id,
    required this.postId,
    required this.donorId,
    required this.requesterId,
    required this.requesterName,
    required this.requesterNumber,
    required this.requesterAddress,
    this.status = 'Pending',
    required this.createdAt,
    required this.postTitle,
    required this.postImageUrl,
    required this.postType,
  });

  factory FoodRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return FoodRequestModel(
      id: id,
      postId: map['postId'] ?? '',
      donorId: map['donorId'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterNumber: map['requesterNumber'] ?? '',
      requesterAddress: map['requesterAddress'] ?? '',
      status: map['status'] ?? 'Pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      postTitle: map['postTitle'] ?? '',
      postImageUrl: map['postImageUrl'] ?? '',
      postType: map['postType'] ?? 'Free',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'donorId': donorId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterNumber': requesterNumber,
      'requesterAddress': requesterAddress,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'postTitle': postTitle,
      'postImageUrl': postImageUrl,
      'postType': postType,
    };
  }
}
