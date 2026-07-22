import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/review_controller.dart';
import 'package:food_bridge/data/post_repository.dart';
import 'package:food_bridge/models/food_request_model.dart';
import 'package:food_bridge/models/review_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/screens/chat/chat_screen.dart';
import 'package:food_bridge/views/screens/user/payment_screen.dart';
import 'package:food_bridge/views/widgets/empty_state_widget.dart';
import 'package:food_bridge/views/widgets/loading_state_widget.dart';
import 'package:food_bridge/views/widgets/review_dialog.dart';
import 'package:get/get.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final PostRepository _repository = PostRepository();
  final ReviewController _reviewController = Get.put(ReviewController());
  bool _isLoading = true;
  List<FoodRequestModel> _requests = [];
  final Map<String, bool> _hasReviewed = {};

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _repository.getMyRequests();
      _hasReviewed.clear();
      for (final request in requests.where((r) => r.status == 'Completed')) {
        final existing = await _reviewController.getExistingReview(
          request.id,
          request.requesterId,
        );
        _hasReviewed[request.id] = existing != null;
      }
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch requests: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showReviewDialog(FoodRequestModel request) {
    final type = request.postType == 'Sale'
        ? ReviewType.buyerToSeller
        : ReviewType.volunteerToDonor;

    ReviewDialog.show(
      context: context,
      title: 'Rate ${request.postType == 'Sale' ? 'Seller' : 'Donor'}',
      subtitle: 'How was your experience with "${request.postTitle}"?',
      onSubmit: (rating, comment) => _reviewController.submitReview(
        reviewedUserId: request.donorId,
        reviewedUserName: 'Donor',
        rating: rating,
        comment: comment,
        type: type,
        requestId: request.id,
        postId: request.postId,
      ).then((success) {
        if (success) {
          setState(() => _hasReviewed[request.id] = true);
        }
        return success;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Collections')),
      body: _isLoading
          ? const LoadingStateWidget()
          : _requests.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.inventory_2_outlined,
                  title: 'No requests yet',
                  subtitle: 'Start collecting or buying food from the home feed.',
                  actionLabel: 'Explore Food Hub',
                  onAction: () => Get.back(),
                )
              : RefreshIndicator(
                  onRefresh: _fetchRequests,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: AppSpacing.screenPadding,
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(_requests[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildRequestCard(FoodRequestModel request) {
    final canReview = request.status == 'Completed' &&
        !(_hasReviewed[request.id] ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Image.network(
                    request.postImageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
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
                      Text(request.postTitle, style: AppTypography.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Requested on ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildStatusBadge(request.status),
                    ],
                  ),
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
                    Text('Type', style: AppTypography.bodySmall),
                    Text(request.postType, style: AppTypography.titleMedium),
                  ],
                ),
                Row(
                  children: [
                    if (request.status == 'Approved' || request.status == 'Completed') ...[
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                        onPressed: () async {
                          Get.dialog(
                            const Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );
                          final donorDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(request.donorId)
                              .get();
                          Get.back(); // close loading indicator
                          final donorName = donorDoc.exists
                              ? (donorDoc.data()?['name'] ?? 'Donor')
                              : 'Donor';
                          Get.to(() => ChatScreen(
                                peerId: request.donorId,
                                peerName: donorName,
                              ));
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (request.status == 'Approved' && request.postType == 'Sale') ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => PaymentScreen(request: request))?.then((_) => _fetchRequests());
                        },
                        icon: const Icon(Icons.payment_outlined, size: 16),
                        label: const Text('Pay Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (canReview)
                      ElevatedButton.icon(
                        onPressed: () => _showReviewDialog(request),
                        icon: const Icon(Icons.star_outline, size: 16),
                        label: const Text('Rate'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      )
                    else if (request.status == 'Completed' &&
                        (_hasReviewed[request.id] ?? false))
                      Text(
                        'Reviewed',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                        ),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = AppColors.warning;
      case 'approved':
        color = AppColors.success;
      case 'payment required':
        color = Colors.purple;
      case 'paid':
        color = Colors.blue;
      case 'ready for pickup':
        color = Colors.indigo;
      case 'rejected':
        color = AppColors.error;
      case 'completed':
        color = AppColors.info;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}
