class PaymentModel {
  final String paymentId;
  final String orderId;
  final String method;
  final double amount;
  final String status;
  final String transactionId;

  PaymentModel({
    required this.paymentId,
    required this.orderId,
    required this.method,
    required this.amount,
    required this.status,
    required this.transactionId,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      paymentId: id,
      orderId: map['orderId'] ?? '',
      method: map['method'] ?? '',
      amount: map['amount'] is num ? (map['amount'] as num).toDouble() : 0.0,
      status: map['status'] ?? '',
      transactionId: map['transactionId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'method': method,
      'amount': amount,
      'status': status,
      'transactionId': transactionId,
    };
  }
}
