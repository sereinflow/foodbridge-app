import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/controllers/review_controller.dart';
import 'package:food_bridge/data/post_repository.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/controllers/home_controller.dart';
import 'package:food_bridge/models/review_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/screens/chat/chat_screen.dart';
import 'package:food_bridge/views/screens/post/create_post_screen.dart';
import 'package:food_bridge/views/screens/user/post_requests_screen.dart';
import 'package:food_bridge/views/screens/user/user_profile_details_screen.dart';
import 'package:food_bridge/views/screens/user/report_dialog.dart';
import 'package:food_bridge/views/widgets/review_dialog.dart';
import 'package:food_bridge/views/screens/user/checkout_screen.dart';
import 'package:get/get.dart';

class FoodPostDetailsScreen extends StatefulWidget {
  final FoodPostModel post;

  const FoodPostDetailsScreen({super.key, required this.post});

  @override
  State<FoodPostDetailsScreen> createState() => _FoodPostDetailsScreenState();
}

class _FoodPostDetailsScreenState extends State<FoodPostDetailsScreen> {
  FoodPostModel get post => widget.post;
  bool _isOwnPost = false;
  bool _canChat = false;
  bool _hasCompletedRequest = false;
  bool _hasReviewed = false;
  String? _requestId;

  @override
  void initState() {
    super.initState();
    _checkRequestStatus();
  }

  Future<void> _checkRequestStatus() async {
    final currentUserId = Get.find<AuthController>().userModel.value?.uid ?? '';
    if (currentUserId.isEmpty) return;

    if (widget.post.userId == currentUserId) {
      setState(() {
        _isOwnPost = true;
      });
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('food_requests')
          .where('postId', isEqualTo: widget.post.id)
          .where('requesterId', isEqualTo: currentUserId)
          .get();

      if (query.docs.isNotEmpty) {
        final requestDoc = query.docs.first;
        final status = requestDoc.data()['status'] as String?;
        final reqId = requestDoc.id;

        final isApprovedOrCompleted = status == 'Approved' || status == 'Completed';
        final isCompleted = status == 'Completed';

        bool reviewed = false;
        if (isCompleted) {
          final reviewQuery = await FirebaseFirestore.instance
              .collection('reviews')
              .where('requestId', isEqualTo: reqId)
              .where('reviewerId', isEqualTo: currentUserId)
              .get();
          reviewed = reviewQuery.docs.isNotEmpty;
        }

        setState(() {
          _requestId = reqId;
          _canChat = isApprovedOrCompleted;
          _hasCompletedRequest = isCompleted;
          _hasReviewed = reviewed;
        });
      }
    } catch (e) {
      debugPrint("Error checking post requests: $e");
    }
  }

  void _showReviewDialog() {
    if (_requestId == null) return;

    final type = widget.post.type == 'Sale'
        ? ReviewType.buyerToSeller
        : ReviewType.volunteerToDonor;

    ReviewDialog.show(
      context: context,
      title: widget.post.type == 'Sale' ? 'Rate Seller' : 'Rate Donor',
      subtitle: 'How was your experience with "${widget.post.title}"?',
      onSubmit: (rating, comment) {
        final reviewController = Get.put(ReviewController());
        return reviewController.submitReview(
          reviewedUserId: widget.post.userId,
          reviewedUserName: widget.post.userName,
          rating: rating,
          comment: comment,
          type: type,
          requestId: _requestId!,
          postId: widget.post.id,
        ).then((success) {
          if (success) {
            setState(() => _hasReviewed = true);
          }
          return success;
        });
      },
    );
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: "Delete Listing",
      middleText: "Are you sure you want to permanently delete this listing?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () async {
        Get.back(); // Close dialog
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        try {
          final postRepository = PostRepository();
          await postRepository.deleteFoodPost(widget.post.id);
          Get.back(); // Close loading
          Get.back(); // Close details screen and go back
          Get.snackbar("Success", "Listing deleted successfully");
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchData();
          }
        } catch (e) {
          Get.back(); // Close loading
          Get.snackbar("Error", "Failed to delete listing: $e");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(context),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              post.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: post.type == 'Free'
                                      ? AppColors.greenAccent
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  post.type == 'Free' ? 'free'.tr : 'sale'.tr,
                                  style: TextStyle(
                                    color: post.type == 'Free'
                                          ? AppColors.primary
                                          : Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (_isOwnPost) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Your Post",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.pickupLocation,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => UserProfileDetailsScreen(userId: post.userId));
                        },
                        child: _buildInfoRow(
                          Icons.person_outline,
                          'donor'.tr,
                          post.userName,
                          clickable: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.inventory_2_outlined,
                        'quantity'.tr,
                        post.quantity,
                      ),
                      if (post.type == 'Sale') ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.payments_outlined,
                          'price'.tr,
                          '${'bdt'.tr} ${post.price.toStringAsFixed(0)}',
                        ),
                      ],
                      const SizedBox(height: 25),
                      Text(
                        'descriptions'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        post.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildSafetyVerificationSection(),
                      const SizedBox(height: 25),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          color: AppColors.card,
                          child: const Center(
                            child: Icon(
                              Icons.map_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 56,
              child: _isOwnPost
                  ? Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() => PostRequestsScreen(
                                    postId: post.id,
                                    postTitle: post.title,
                                  ));
                            },
                            icon: const Icon(Icons.list_alt, color: Colors.white, size: 18),
                            label: const Text(
                              "Requests",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.to(() => CreatePostScreen(existingPost: post));
                            },
                            icon: const Icon(Icons.edit, color: AppColors.primary, size: 18),
                            label: const Text(
                              "Edit",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            _confirmDelete();
                          },
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.error.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _canChat
                      ? _hasCompletedRequest && !_hasReviewed
                          ? Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _showReviewDialog,
                                    icon: const Icon(Icons.star_outline, color: AppColors.primary),
                                    label: Text(
                                      post.type == 'Sale' ? 'Rate Seller' : 'Rate Donor',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Get.to(() => ChatScreen(
                                            peerId: post.userId,
                                            peerName: post.userName,
                                          ));
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                                    label: const Text(
                                      "Chat",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ElevatedButton.icon(
                              onPressed: () {
                                Get.to(() => ChatScreen(
                                      peerId: post.userId,
                                      peerName: post.userName,
                                    ));
                              },
                              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                              label: Text(
                                post.type == 'Sale' ? "Chat with Seller" : "Chat with Donor",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                            )
                      : ElevatedButton(
                          onPressed: () {
                            if (post.type == 'Sale') {
                              Get.to(() => CheckoutScreen(post: post));
                            } else {
                              Get.find<HomeController>().collect(post);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            post.type == 'Free' ? 'req_to_collect'.tr : "Buy Now",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: post.id,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            child: Image.network(
              post.imageUrl,
              height: 350,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 350,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ),
        // Symmetrical Report Button
        Positioned(
          top: 50,
          right: 20,
          child: GestureDetector(
            onTap: () {
              ReportDialog.show(
                context: context,
                reportType: 'food',
                targetId: post.id,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_outlined,
                color: AppColors.error,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool clickable = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.greenAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  decoration: clickable ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        if (clickable)
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildSafetyVerificationSection() {
    if (post.expiryDate == null &&
        post.storageTemperature == null &&
        post.safetyAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    bool isExpiringSoon = false;
    if (post.expiryDate != null) {
      final hoursUntilExpiry = post.expiryDate!.difference(DateTime.now()).inHours;
      isExpiringSoon = hoursUntilExpiry < 24 && hoursUntilExpiry >= 0;
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.red.shade400, size: 20),
              const SizedBox(width: 8),
              Text(
                'safety_verif'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (post.expiryDate != null) ...[
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "${'expires'.tr}: ${post.expiryDate!.day}/${post.expiryDate!.month}/${post.expiryDate!.year} ${post.expiryDate!.hour}:${post.expiryDate!.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 14,
                    color: isExpiringSoon ? Colors.red : AppColors.textPrimary,
                    fontWeight: isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (post.storageTemperature != null) ...[
            Row(
              children: [
                const Icon(Icons.thermostat, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "${'storage_temp'.tr}: ${post.storageTemperature}",
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (post.safetyAlerts.isNotEmpty) ...[
            const Divider(),
            ...post.safetyAlerts.map((alert) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          alert,
                          style: const TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
