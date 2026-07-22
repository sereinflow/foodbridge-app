import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/screens/user/main_layout_screen.dart';
import 'package:food_bridge/views/screens/user/my_orders_screen.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:get/get.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final String paymentMethod;
  final String paymentStatus;
  final double totalPrice;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Beautiful Checkmark Animation / Success Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                "Order Placed!",
                style: AppTypography.displayMedium.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                "Your order has been placed successfully.",
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildConfirmationRow("Order ID", orderId.substring(0, 8).toUpperCase(), isCopyable: true, fullValue: orderId),
                    const Divider(height: 24),
                    _buildConfirmationRow("Payment Method", paymentMethod),
                    const Divider(height: 24),
                    _buildConfirmationRow("Payment Status", paymentStatus),
                    const Divider(height: 24),
                    _buildConfirmationRow("Estimated Pickup", "Within 2 Hours"),
                    const Divider(height: 24),
                    _buildConfirmationRow(
                      "Total Price",
                      "BDT ${totalPrice.toStringAsFixed(0)}",
                      valueColor: AppColors.primary,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Actions
              CustomBWButton(
                isLoading: false,
                title: "View My Orders",
                bgColor: AppColors.primary,
                shadowLight: Colors.white.withValues(alpha: 0.9),
                shadowDark: Colors.black.withValues(alpha: 0.12),
                textColor: Colors.white,
                onTap: () => Get.offAll(() => const MyOrdersScreen()),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Get.offAll(() => const MainLayoutScreen()),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppColors.primary, width: 2),
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
    bool isCopyable = false,
    String? fullValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Row(
          children: [
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (isCopyable) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: fullValue ?? value));
                  Get.snackbar("Copied", "Order ID copied to clipboard!");
                },
                child: const Icon(Icons.copy, size: 14, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
