import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;

  final String? phone;
  final String? bio;
  final List<String> savedPosts;
  final String? userType;
  final double averageRating;
  final int reviewCount;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.bio,
    this.savedPosts = const [],
    this.userType,
    this.averageRating = 0,
    this.reviewCount = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'bio': bio,
      'savedPosts': savedPosts,
      'userType': userType,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      phone: map['phone'],
      bio: map['bio'],
      savedPosts: List<String>.from(map['savedPosts'] ?? []),
      userType: map['userType'],
      averageRating: map['averageRating'] is num
          ? (map['averageRating'] as num).toDouble()
          : 0,
      reviewCount: map['reviewCount'] is int
          ? map['reviewCount'] as int
          : (map['reviewCount'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? bio,
    List<String>? savedPosts,
    String? userType,
    double? averageRating,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      savedPosts: savedPosts ?? this.savedPosts,
      userType: userType ?? this.userType,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
