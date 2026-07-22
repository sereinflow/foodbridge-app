import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/home_controller.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/models/food_request_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatefulWidget {
  final FoodRequestModel request;

  const PaymentScreen({super.key, required this.request});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = true;
  FoodPostModel? _post;
  String _selectedMethod = 'bKash';

  @override
  void initState() {
    super.initState();
    _fetchPostDetails();
  }

  Future<void> _fetchPostDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('food_posts')
          .doc(widget.request.postId)
          .get();
      if (doc.exists) {
        setState(() {
          _post = FoodPostModel.fromMap(doc.data()!, doc.id);
          _isLoading = false;
        });
      } else {
        Get.snackbar("Error", "Food listing no longer exists");
        Get.back();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load listing: $e");
      Get.back();
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);
    // Simulate gateway delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      // 1. Update request status to 'Paid'
      await FirebaseFirestore.instance
          .collection('food_requests')
          .doc(widget.request.id)
          .update({'status': 'Paid'});

      // 2. Show success dialog
      Get.back(); // close payment screen
      Get.defaultDialog(
        title: "Payment Successful",
        middleText: "Your payment via $_selectedMethod was successful! The status has been updated to Paid.",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primary,
        onConfirm: () {
          Get.back();
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchData();
          }
        },
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to complete payment: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Secure Payment"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummaryCard(),
                  const SizedBox(height: AppSpacing.lg),
                  Text("Select Payment Method", style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  _buildPaymentMethods(),
                  const SizedBox(height: AppSpacing.xxl),
                  CustomBWButton(
                    isLoading: _isLoading,
                    title: "Pay BDT ${_post!.price.toStringAsFixed(0)}",
                    bgColor: AppColors.primary,
                    shadowLight: Colors.white.withValues(alpha: 0.9),
                    shadowDark: Colors.black.withValues(alpha: 0.12),
                    textColor: Colors.white,
                    onTap: _processPayment,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Summary", style: AppTypography.headlineMedium.copyWith(color: AppColors.primary)),
            const Divider(height: 24),
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Image.network(
                    widget.request.postImageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.surfaceMuted,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.request.postTitle, style: AppTypography.titleLarge),
                      const SizedBox(height: 4),
                      Text("Seller: ${_post!.userName}", style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Quantity", style: AppTypography.bodyMedium),
                Text(_post!.quantity, style: AppTypography.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Unit Price", style: AppTypography.bodyMedium),
                Text("BDT ${_post!.price.toStringAsFixed(0)}", style: AppTypography.titleMedium),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Amount", style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                Text("BDT ${_post!.price.toStringAsFixed(0)}", style: AppTypography.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'name': 'bKash', 'icon': Icons.account_balance_wallet, 'sub': 'Simulated mobile wallet'},
      {'name': 'Nagad', 'icon': Icons.account_balance_wallet_outlined, 'sub': 'Simulated mobile wallet'},
      {'name': 'Card', 'icon': Icons.credit_card, 'sub': 'Visa, Mastercard, AMEX'},
      {'name': 'Cash on Pickup', 'icon': Icons.payments_outlined, 'sub': 'Pay cash when collecting'},
    ];

    return Column(
      children: methods.map((m) {
        final isSelected = _selectedMethod == m['name'];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200, width: 2),
          ),
          child: ListTile(
            leading: Icon(m['icon'] as IconData, color: isSelected ? AppColors.primary : Colors.grey),
            title: Text(m['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(m['sub'] as String, style: const TextStyle(fontSize: 11)),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : const Icon(Icons.circle_outlined, color: Colors.grey),
            onTap: () {
              setState(() {
                _selectedMethod = m['name'] as String;
              });
            },
          ),
        );
      }).toList(),
    );
  }
}
