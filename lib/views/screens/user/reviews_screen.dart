import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/controllers/review_controller.dart';
import 'package:food_bridge/models/review_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/widgets/custom_confirmation_dialog.dart';
import 'package:food_bridge/views/widgets/empty_state_widget.dart';
import 'package:food_bridge/views/widgets/loading_state_widget.dart';
import 'package:food_bridge/views/widgets/review_card.dart';
import 'package:food_bridge/views/widgets/review_dialog.dart';
import 'package:food_bridge/views/widgets/star_rating_widget.dart';
import 'package:get/get.dart';

class ReviewsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final bool showMyReviews;

  const ReviewsScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.showMyReviews = false,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewController _controller = Get.put(ReviewController());
  final AuthController _authController = Get.find<AuthController>();
  double _averageRating = 0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (widget.showMyReviews) {
      await _controller.fetchReviewsByUser(widget.userId);
    } else {
      await _controller.fetchReviewsForUser(widget.userId);
      await _fetchUserRating();
    }
  }

  Future<void> _fetchUserRating() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (doc.exists && mounted) {
      final data = doc.data()!;
      setState(() {
        _averageRating = (data['averageRating'] as num?)?.toDouble() ?? 0;
        _reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authController.userModel.value?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.showMyReviews ? 'My Reviews' : 'Reviews'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const LoadingStateWidget();
        }

        if (_controller.reviews.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.rate_review_outlined,
            title: 'No reviews yet',
            subtitle: widget.showMyReviews
                ? 'Reviews you write will appear here.'
                : 'This user has not received any reviews yet.',
          );
        }

        return RefreshIndicator(
          onRefresh: _loadReviews,
          color: AppColors.primary,
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              if (!widget.showMyReviews)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Column(
                    children: [
                      Text(widget.userName, style: AppTypography.headlineMedium),
                      const SizedBox(height: AppSpacing.md),
                      StarRatingWidget(rating: _averageRating, size: 28),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${_averageRating.toStringAsFixed(1)} ($_reviewCount reviews)',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ..._controller.reviews.map((review) {
                final isOwnReview = review.reviewerId == currentUserId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ReviewCard(
                    review: review,
                    showActions: widget.showMyReviews && isOwnReview,
                    onEdit: () => _editReview(review),
                    onDelete: () => _deleteReview(review),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  void _editReview(ReviewModel review) {
    ReviewDialog.show(
      context: context,
      title: 'Edit Review',
      subtitle: 'Update your review for ${review.reviewedUserName}',
      existingReview: review,
      onSubmit: (rating, comment) =>
          _controller.updateReview(review, rating, comment),
    );
  }

  void _deleteReview(ReviewModel review) {
    CustomConfirmationDialog.show(
      title: 'Delete Review',
      message: 'Are you sure you want to delete this review?',
      onConfirm: () {
        Get.back();
        _controller.deleteReview(review);
      },
    );
  }
}
