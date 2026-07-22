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
  final List<String> tags;
  final DateTime? expiryDate;
  final String? storageTemperature;
  final List<String> safetyAlerts;

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
    this.tags = const [],
    this.expiryDate,
    this.storageTemperature,
    this.safetyAlerts = const [],
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
      tags: List<String>.from(map['tags'] ?? []),
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate(),
      storageTemperature: map['storageTemperature'],
      safetyAlerts: List<String>.from(map['safetyAlerts'] ?? []),
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
      'tags': tags,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'storageTemperature': storageTemperature,
      'safetyAlerts': safetyAlerts,
    };
  }

  FoodPostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? type,
    String? title,
    String? description,
    String? quantity,
    String? pickupLocation,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
    double? price,
    String? claimedBy,
    String? claimerContact,
    List<String>? tags,
    DateTime? expiryDate,
    String? storageTemperature,
    List<String>? safetyAlerts,
  }) {
    return FoodPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      price: price ?? this.price,
      claimedBy: claimedBy ?? this.claimedBy,
      claimerContact: claimerContact ?? this.claimerContact,
      tags: tags ?? this.tags,
      expiryDate: expiryDate ?? this.expiryDate,
      storageTemperature: storageTemperature ?? this.storageTemperature,
      safetyAlerts: safetyAlerts ?? this.safetyAlerts,
    );
  }
}
