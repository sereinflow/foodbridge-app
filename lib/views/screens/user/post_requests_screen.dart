import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/controllers/review_controller.dart';
import 'package:food_bridge/data/post_repository.dart';
import 'package:food_bridge/models/food_request_model.dart';
import 'package:food_bridge/models/review_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/widgets/loading_state_widget.dart';
import 'package:food_bridge/views/widgets/review_dialog.dart';
import 'package:get/get.dart';

class PostRequestsScreen extends StatefulWidget {
  final String postId;
  final String postTitle;

  const PostRequestsScreen({
    super.key,
    required this.postId,
    required this.postTitle,
  });

  @override
  State<PostRequestsScreen> createState() => _PostRequestsScreenState();
}

class _PostRequestsScreenState extends State<PostRequestsScreen> {
  final PostRepository _repository = PostRepository();
  final ReviewController _reviewController = Get.put(ReviewController());
  final AuthController _authController = Get.find<AuthController>();
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
      final requests = await _repository.getRequestsForPost(widget.postId);
      final donorId = _authController.userModel.value?.uid ?? '';
      _hasReviewed.clear();
      for (final request in requests.where((r) => r.status == 'Completed')) {
        final existing = await _reviewController.getExistingReview(
          request.id,
          donorId,
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

  Future<void> _updateStatus(String requestId, String status) async {
    try {
      await _repository.updateRequestStatus(requestId, status);
      Get.snackbar('Success', 'Request status updated to $status');
      _fetchRequests();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  void _showReviewDialog(FoodRequestModel request) {
    ReviewDialog.show(
      context: context,
      title: 'Rate Volunteer',
      subtitle: 'How was your experience with ${request.requesterName}?',
      onSubmit: (rating, comment) => _reviewController.submitReview(
        reviewedUserId: request.requesterId,
        reviewedUserName: request.requesterName,
        rating: rating,
        comment: comment,
        type: ReviewType.donorToVolunteer,
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
      appBar: AppBar(
        title: Text(
          'Requests: ${widget.postTitle}',
          style: AppTypography.titleLarge,
        ),
      ),
      body: _isLoading
          ? const LoadingStateWidget()
          : _requests.isEmpty
              ? const Center(child: Text('No requests for this item yet.'))
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
        request.postType == 'Free' &&
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterName,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Requested on ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
            const Divider(height: 25),
            _buildInfoRow(Icons.phone, 'Phone', request.requesterNumber),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.location_on, 'Address', request.requesterAddress),
            const SizedBox(height: 20),
            if (request.status == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(request.id, 'Rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(request.id, 'Approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              )
            else if (request.status == 'Approved')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus(request.id, 'Completed'),
                  child: const Text('Mark as Completed'),
                ),
              )
            else if (canReview)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showReviewDialog(request),
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Rate Volunteer'),
                ),
              )
            else if (request.status == 'Completed' &&
                (_hasReviewed[request.id] ?? false))
              Center(
                child: Text(
                  'Review submitted',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ', style: AppTypography.bodyMedium),
        Expanded(
          child: Text(value, style: AppTypography.titleMedium),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = AppColors.warning;
      case 'approved':
        color = AppColors.success;
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
      ),
      child: Text(
        status,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}
