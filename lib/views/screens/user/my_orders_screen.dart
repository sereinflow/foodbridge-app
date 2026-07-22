import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/models/order_model.dart';
import 'package:food_bridge/models/refund_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/screens/user/main_layout_screen.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:food_bridge/views/widgets/custom_confirmation_dialog.dart';
import 'package:food_bridge/views/widgets/empty_state_widget.dart';
import 'package:food_bridge/views/widgets/loading_state_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _isLoading = true;
  List<OrderModel> _orders = [];
  final Map<String, FoodPostModel> _postsCache = {};
  final Map<String, RefundModel> _refundsCache = {};

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    try {
      final buyerId = Get.find<AuthController>().userModel.value?.uid ?? '';
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('buyerId', isEqualTo: buyerId)
          .get();

      final orders = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Batch load post and refund details
      for (final order in orders) {
        if (!_postsCache.containsKey(order.foodPostId)) {
          final postDoc = await FirebaseFirestore.instance
              .collection('food_posts')
              .doc(order.foodPostId)
              .get();
          if (postDoc.exists) {
            _postsCache[order.foodPostId] = FoodPostModel.fromMap(postDoc.data()!, postDoc.id);
          }
        }

        // Fetch refund if exists
        final refundSnapshot = await FirebaseFirestore.instance
            .collection('refunds')
            .where('orderId', isEqualTo: order.orderId)
            .limit(1)
            .get();
        if (refundSnapshot.docs.isNotEmpty) {
          _refundsCache[order.orderId] = RefundModel.fromMap(
            refundSnapshot.docs.first.data(),
            refundSnapshot.docs.first.id,
          );
        }
      }

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch orders: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelOrder(OrderModel order) async {
    CustomConfirmationDialog.show(
      title: "Cancel Order",
      message: "Are you sure you want to cancel this order? This action cannot be undone.",
      onConfirm: () async {
        Get.back(); // close confirmation dialog
        setState(() => _isLoading = true);

        try {
          final isPrepaid = order.paymentMethod != 'COD';
          final newStatus = isPrepaid ? 'Refund Requested' : 'Cancelled';

          final batch = FirebaseFirestore.instance.batch();
          final orderRef = FirebaseFirestore.instance.collection('orders').doc(order.orderId);

          batch.update(orderRef, {
            'orderStatus': newStatus,
            'paymentStatus': isPrepaid ? 'Refund Pending' : 'Cancelled',
          });

          // Create refund entry if prepaid
          if (isPrepaid) {
            final refundId = const Uuid().v4();
            final refundRef = FirebaseFirestore.instance.collection('refunds').doc(refundId);
            final refund = RefundModel(
              refundId: refundId,
              orderId: order.orderId,
              amount: order.totalPrice,
              status: 'Refund Requested',
              reason: "Order canceled by buyer",
              createdAt: DateTime.now(),
            );
            batch.set(refundRef, refund.toMap());
          }

          // Restore food post status if it was reserved
          final postRef = FirebaseFirestore.instance.collection('food_posts').doc(order.foodPostId);
          batch.update(postRef, {'status': 'Available'});

          await batch.commit();
          Get.snackbar("Success", isPrepaid ? "Cancel request submitted. Refund is processing." : "Order cancelled successfully.");
          _fetchOrders();
        } catch (e) {
          Get.snackbar("Error", "Failed to cancel order: $e");
          setState(() => _isLoading = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.offAll(() => const MainLayoutScreen()),
        ),
      ),
      body: _isLoading
          ? const LoadingStateWidget()
          : _orders.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.shopping_basket_outlined,
                  title: "No Orders Yet",
                  subtitle: "You haven't placed any orders yet.",
                )
              : ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final post = _postsCache[order.foodPostId];
                    final refund = _refundsCache[order.orderId];
                    return _buildOrderCard(order, post, refund);
                  },
                ),
    );
  }

  Widget _buildOrderCard(OrderModel order, FoodPostModel? post, RefundModel? refund) {
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);
    final isCancellable = order.orderStatus == 'Pending Payment' || order.orderStatus == 'Processing';

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
                Text("Order ID: ${order.orderId.substring(0, 8).toUpperCase()}", style: AppTypography.bodySmall),
                _buildStatusBadge(order.orderStatus),
              ],
            ),
            const SizedBox(height: 4),
            Text(formattedDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: post != null
                      ? Image.network(
                          post.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade200,
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post?.title ?? "Loading post info...", style: AppTypography.titleMedium),
                      const SizedBox(height: 4),
                      Text("Seller: ${post?.userName ?? '...'}", style: AppTypography.bodySmall),
                      const SizedBox(height: 4),
                      Text("Qty: ${order.quantity}", style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                Text(
                  "BDT ${order.totalPrice.toStringAsFixed(0)}",
                  style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Payment: ${order.paymentMethod}", style: AppTypography.bodySmall),
                    Text("Status: ${order.paymentStatus}", style: AppTypography.bodySmall),
                  ],
                ),
                if (isCancellable)
                  ElevatedButton(
                    onPressed: () => _cancelOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text("Cancel Order", style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            if (refund != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.purple, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Refund status: ${refund.status} (Reason: ${refund.reason})",
                        style: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending payment':
        color = Colors.amber;
      case 'paid':
        color = Colors.blue;
      case 'payment on delivery':
        color = Colors.teal;
      case 'processing':
        color = Colors.purple;
      case 'ready for pickup':
        color = Colors.indigo;
      case 'completed':
        color = Colors.green;
      case 'refund requested':
        color = Colors.pink;
      case 'refund approved':
        color = Colors.purpleAccent;
      case 'refunded':
        color = Colors.deepPurple;
      case 'cancelled':
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
