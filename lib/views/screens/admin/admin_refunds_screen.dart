import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/models/refund_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/widgets/empty_state_widget.dart';
import 'package:food_bridge/views/widgets/loading_state_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminRefundsScreen extends StatefulWidget {
  const AdminRefundsScreen({super.key});

  @override
  State<AdminRefundsScreen> createState() => _AdminRefundsScreenState();
}

class _AdminRefundsScreenState extends State<AdminRefundsScreen> {
  bool _isLoading = true;
  List<RefundModel> _refunds = [];

  @override
  void initState() {
    super.initState();
    _fetchRefunds();
  }

  Future<void> _fetchRefunds() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('refunds')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _refunds = snapshot.docs.map((doc) => RefundModel.fromMap(doc.data(), doc.id)).toList();
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch refund requests: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processRefund(RefundModel refund, String action) async {
    setState(() => _isLoading = true);

    try {
      final batch = FirebaseFirestore.instance.batch();
      final refundRef = FirebaseFirestore.instance.collection('refunds').doc(refund.refundId);
      final orderRef = FirebaseFirestore.instance.collection('orders').doc(refund.orderId);

      String newRefundStatus = '';
      String newOrderStatus = '';

      if (action == 'approve') {
        newRefundStatus = 'Refunded';
        newOrderStatus = 'Refunded';
      } else {
        newRefundStatus = 'Refund Rejected';
        newOrderStatus = 'Processing'; // Reset back to processing
      }

      batch.update(refundRef, {'status': newRefundStatus});
      batch.update(orderRef, {
        'orderStatus': newOrderStatus,
        'paymentStatus': newRefundStatus,
      });

      await batch.commit();
      Get.snackbar("Success", "Refund request has been updated to: $newRefundStatus");
      _fetchRefunds();
    } catch (e) {
      Get.snackbar("Error", "Failed to process refund: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Manage Refunds", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const LoadingStateWidget()
          : _refunds.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.currency_exchange_outlined,
                  title: "No Refunds",
                  subtitle: "No refund requests found.",
                )
              : ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: _refunds.length,
                  itemBuilder: (context, index) {
                    final refund = _refunds[index];
                    return _buildRefundCard(refund);
                  },
                ),
    );
  }

  Widget _buildRefundCard(RefundModel refund) {
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(refund.createdAt);
    final isPending = refund.status == 'Refund Requested';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Refund ID: ${refund.refundId.substring(0, 8).toUpperCase()}", style: AppTypography.bodySmall),
                _buildRefundStatusBadge(refund.status),
              ],
            ),
            const SizedBox(height: 4),
            Text("Date: $formattedDate", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const Divider(height: 24),
            Text("Order ID: ${refund.orderId.substring(0, 8).toUpperCase()}", style: AppTypography.titleMedium),
            const SizedBox(height: 6),
            Text("Reason: ${refund.reason}", style: AppTypography.bodyMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Amount: BDT ${refund.amount.toStringAsFixed(0)}",
                  style: AppTypography.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                if (isPending)
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => _processRefund(refund, 'reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Reject"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _processRefund(refund, 'approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Approve"),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'refund requested':
        color = Colors.pink;
      case 'refunded':
      case 'refund approved':
        color = Colors.green;
      case 'refund rejected':
        color = Colors.red;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
