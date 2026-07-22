import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/models/order_model.dart';
import 'package:food_bridge/models/payment_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/screens/user/order_confirmation_screen.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class CheckoutScreen extends StatefulWidget {
  final FoodPostModel post;

  const CheckoutScreen({super.key, required this.post});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _quantity = 1;
  int _maxQuantity = 1;
  String _selectedMethod = 'COD'; // COD, Card, bKash, Nagad, Bank Transfer

  // Form controllers
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  final _walletNumberController = TextEditingController();
  final _walletTxnIdController = TextEditingController();

  final _bankAccountController = TextEditingController();
  final _bankRefController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Parse max quantity from listing description/quantity string
    final parsed = int.tryParse(widget.post.quantity.replaceAll(RegExp(r'[^0-9]'), ''));
    _maxQuantity = (parsed != null && parsed > 0) ? parsed : 1;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _walletNumberController.dispose();
    _walletTxnIdController.dispose();
    _bankAccountController.dispose();
    _bankRefController.dispose();
    super.dispose();
  }

  double get _totalPrice => widget.post.price * _quantity;

  Future<void> _placeOrder() async {
    if (_selectedMethod != 'COD') {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final buyerId = Get.find<AuthController>().userModel.value?.uid ?? '';
      final orderId = const Uuid().v4();
      final paymentId = const Uuid().v4();

      String orderStatus = 'Processing';
      String paymentStatus = 'Paid';

      if (_selectedMethod == 'COD') {
        orderStatus = 'Pending Pickup';
        paymentStatus = 'Payment on Delivery';
      } else if (_selectedMethod == 'Bank Transfer') {
        orderStatus = 'Pending Payment';
        paymentStatus = 'Awaiting Verification';
      }

      // Create Order
      final order = OrderModel(
        orderId: orderId,
        buyerId: buyerId,
        sellerId: widget.post.userId,
        foodPostId: widget.post.id,
        quantity: _quantity,
        totalPrice: _totalPrice,
        paymentMethod: _selectedMethod,
        paymentStatus: paymentStatus,
        orderStatus: orderStatus,
        createdAt: DateTime.now(),
      );

      // Create Payment
      String transactionId = '';
      if (_selectedMethod == 'Card') {
        transactionId = 'TXN-CARD-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      } else if (_selectedMethod == 'bKash' || _selectedMethod == 'Nagad') {
        transactionId = _walletTxnIdController.text.trim();
      } else if (_selectedMethod == 'Bank Transfer') {
        transactionId = _bankRefController.text.trim();
      } else {
        transactionId = 'COD-ORDER';
      }

      final payment = PaymentModel(
        paymentId: paymentId,
        orderId: orderId,
        method: _selectedMethod,
        amount: _totalPrice,
        status: paymentStatus == 'Paid' ? 'Success' : 'Pending',
        transactionId: transactionId,
      );

      // Save to Firestore
      final batch = FirebaseFirestore.instance.batch();
      final orderRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
      final paymentRef = FirebaseFirestore.instance.collection('payments').doc(paymentId);

      batch.set(orderRef, order.toMap());
      batch.set(paymentRef, payment.toMap());

      // Update food post status if fully reserved/sold
      if (_quantity >= _maxQuantity) {
        final postRef = FirebaseFirestore.instance.collection('food_posts').doc(widget.post.id);
        batch.update(postRef, {'status': 'Reserved'});
      }

      await batch.commit();

      Get.off(() => OrderConfirmationScreen(
            orderId: orderId,
            paymentMethod: _selectedMethod,
            paymentStatus: paymentStatus,
            totalPrice: _totalPrice,
          ));
    } catch (e) {
      Get.snackbar("Error", "Failed to place order: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Resale Checkout", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildListingSummary(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildQuantitySelector(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPaymentSelector(),
                    const SizedBox(height: AppSpacing.lg),
                    if (_selectedMethod != 'COD') _buildPaymentForm(),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomBWButton(
                            isLoading: _isLoading,
                            title: "Continue",
                            bgColor: AppColors.primary,
                            shadowLight: Colors.white.withValues(alpha: 0.9),
                            shadowDark: Colors.black.withValues(alpha: 0.12),
                            textColor: Colors.white,
                            onTap: _placeOrder,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildListingSummary() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.post.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
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
                  Text(widget.post.title, style: AppTypography.titleLarge),
                  const SizedBox(height: 4),
                  Text("Seller: ${widget.post.userName}", style: AppTypography.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.post.pickupLocation,
                          style: AppTypography.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "BDT ${widget.post.price.toStringAsFixed(0)} / unit",
                    style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Quantity", style: AppTypography.titleMedium),
                Text("Max Available: $_maxQuantity", style: AppTypography.bodySmall),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text("$_quantity", style: AppTypography.titleLarge),
                IconButton(
                  onPressed: _quantity < _maxQuantity ? () => setState(() => _quantity++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSelector() {
    final methods = [
      {'name': 'COD', 'label': 'Cash on Delivery', 'icon': Icons.payments_outlined},
      {'name': 'Card', 'label': 'Credit / Debit Card', 'icon': Icons.credit_card},
      {'name': 'bKash', 'label': 'bKash Wallet', 'icon': Icons.account_balance_wallet},
      {'name': 'Nagad', 'label': 'Nagad Wallet', 'icon': Icons.account_balance_wallet_outlined},
      {'name': 'Bank Transfer', 'label': 'Bank Transfer', 'icon': Icons.account_balance},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Method", style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Column(
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
                title: Text(m['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Payment Details", style: AppTypography.titleLarge.copyWith(color: AppColors.primary)),
            const SizedBox(height: AppSpacing.md),
            if (_selectedMethod == 'Card') ...[
              _buildTextField(
                controller: _cardNumberController,
                icon: Icons.credit_card,
                hint: "Card Number (16 digits)",
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.length != 16 || int.tryParse(val) == null) {
                    return "Enter valid 16-digit card number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _cardNameController,
                icon: Icons.person_outline,
                hint: "Cardholder Name",
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Cardholder name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cardExpiryController,
                      icon: Icons.calendar_today,
                      hint: "MM/YY",
                      keyboardType: TextInputType.datetime,
                      validator: (val) {
                        if (val == null || !val.contains('/') || val.length != 5) {
                          return "Use MM/YY";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _cardCvvController,
                      icon: Icons.security,
                      hint: "CVV (3 digits)",
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.length != 3 || int.tryParse(val) == null) {
                          return "Enter 3-digit CVV";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else if (_selectedMethod == 'bKash' || _selectedMethod == 'Nagad') ...[
              _buildTextField(
                controller: _walletNumberController,
                icon: Icons.phone_android,
                hint: "Mobile Number (11 digits)",
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.length != 11 || int.tryParse(val) == null) {
                    return "Enter valid 11-digit mobile number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _walletTxnIdController,
                icon: Icons.receipt_long,
                hint: "Transaction ID",
                validator: (val) {
                  if (val == null || val.trim().length < 8) {
                    return "Enter valid Transaction ID (min 8 chars)";
                  }
                  return null;
                },
              ),
            ] else if (_selectedMethod == 'Bank Transfer') ...[
              _buildTextField(
                controller: _bankAccountController,
                icon: Icons.account_balance_wallet,
                hint: "Account Number",
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().length < 10) {
                    return "Enter valid Account Number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _bankRefController,
                icon: Icons.tag,
                hint: "Reference Number",
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Reference number is required";
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
