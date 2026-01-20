import 'package:cloud_firestore/cloud_firestore.dart';

class FoodPostModel {
  final String id;
  final String userId;
  final String userName;
  final String type;
  final String title;
  final String description;
  final String quantity;
  final String pickupLocation;
  final String imageUrl;
  final String status;
  final DateTime createdAt;
  final double price;
  final String? claimedBy;
  final String? claimerContact;

  FoodPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.title,
    required this.description,
    required this.quantity,
    required this.pickupLocation,
    required this.imageUrl,
    this.status = 'Available',
    required this.createdAt,
    this.price = 0.0,
    this.claimedBy,
    this.claimerContact,
  });

  factory FoodPostModel.fromMap(Map<String, dynamic> map, String id) {
    return FoodPostModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      type: map['type'] ?? 'Free',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      status: map['status'] ?? 'Available',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: map['price'] is num ? (map['price'] as num).toDouble() : 0.0,
      claimedBy: map['claimedBy'],
      claimerContact: map['claimerContact'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'type': type,
      'title': title,
      'description': description,
      'quantity': quantity,
      'pickupLocation': pickupLocation,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'price': price,
      'claimedBy': claimedBy,
      'claimerContact': claimerContact,
    };
  }
}
