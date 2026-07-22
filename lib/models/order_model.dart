import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String buyerId;
  final String sellerId;
  final String foodPostId;
  final int quantity;
  final double totalPrice;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.foodPostId,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      foodPostId: map['foodPostId'] ?? '',
      quantity: map['quantity'] is num ? (map['quantity'] as num).toInt() : 1,
      totalPrice: map['totalPrice'] is num ? (map['totalPrice'] as num).toDouble() : 0.0,
      paymentMethod: map['paymentMethod'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
      orderStatus: map['orderStatus'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'foodPostId': foodPostId,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
