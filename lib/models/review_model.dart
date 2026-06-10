import 'package:cloud_firestore/cloud_firestore.dart';

/// Review types matching FoodBridge rating flows.
enum ReviewType {
  donorToVolunteer,
  volunteerToDonor,
  buyerToSeller,
}

extension ReviewTypeExtension on ReviewType {
  String get value {
    switch (this) {
      case ReviewType.donorToVolunteer:
        return 'donor_to_volunteer';
      case ReviewType.volunteerToDonor:
        return 'volunteer_to_donor';
      case ReviewType.buyerToSeller:
        return 'buyer_to_seller';
    }
  }

  static ReviewType fromString(String value) {
    switch (value) {
      case 'donor_to_volunteer':
        return ReviewType.donorToVolunteer;
      case 'volunteer_to_donor':
        return ReviewType.volunteerToDonor;
      case 'buyer_to_seller':
        return ReviewType.buyerToSeller;
      default:
        return ReviewType.buyerToSeller;
    }
  }
}

class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String reviewedUserId;
  final String reviewedUserName;
  final int rating;
  final String? comment;
  final ReviewType type;
  final String requestId;
  final String postId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewedUserId,
    required this.reviewedUserName,
    required this.rating,
    this.comment,
    required this.type,
    required this.requestId,
    required this.postId,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      reviewedUserId: map['reviewedUserId'] ?? '',
      reviewedUserName: map['reviewedUserName'] ?? '',
      rating: map['rating'] is int
          ? map['rating'] as int
          : (map['rating'] as num?)?.toInt() ?? 0,
      comment: map['comment'],
      type: ReviewTypeExtension.fromString(map['type'] ?? ''),
      requestId: map['requestId'] ?? '',
      postId: map['postId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewedUserId': reviewedUserId,
      'reviewedUserName': reviewedUserName,
      'rating': rating,
      'comment': comment,
      'type': type.value,
      'requestId': requestId,
      'postId': postId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  ReviewModel copyWith({
    int? rating,
    String? comment,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      reviewedUserId: reviewedUserId,
      reviewedUserName: reviewedUserName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      type: type,
      requestId: requestId,
      postId: postId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
