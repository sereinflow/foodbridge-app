import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/data/review_repository.dart';
import 'package:food_bridge/models/food_request_model.dart';
import 'package:food_bridge/models/review_model.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ReviewController extends GetxController {
  final ReviewRepository _repository = ReviewRepository();
  final AuthController _authController = Get.find<AuthController>();
  final _uuid = const Uuid();

  final reviews = <ReviewModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  Future<void> fetchReviewsForUser(String userId) async {
    try {
      isLoading.value = true;
      reviews.value = await _repository.getReviewsForUser(userId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReviewsByUser(String userId) async {
    try {
      isLoading.value = true;
      reviews.value = await _repository.getReviewsByUser(userId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ReviewModel?> getExistingReview(
    String requestId,
    String reviewerId,
  ) {
    return _repository.getReviewForRequest(requestId, reviewerId);
  }

  Future<bool> submitReview({
    required String reviewedUserId,
    required String reviewedUserName,
    required int rating,
    String? comment,
    required ReviewType type,
    required String requestId,
    required String postId,
  }) async {
    final user = _authController.userModel.value;
    if (user == null) return false;

    try {
      isSubmitting.value = true;
      final review = ReviewModel(
        id: _uuid.v4(),
        reviewerId: user.uid,
        reviewerName: user.name,
        reviewedUserId: reviewedUserId,
        reviewedUserName: reviewedUserName,
        rating: rating,
        comment: comment?.trim().isEmpty == true ? null : comment?.trim(),
        type: type,
        requestId: requestId,
        postId: postId,
        createdAt: DateTime.now(),
      );
      await _repository.submitReview(review);
      Get.snackbar('Success', 'Review submitted successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateReview(ReviewModel review, int rating, String? comment) async {
    try {
      isSubmitting.value = true;
      await _repository.updateReview(
        review.copyWith(
          rating: rating,
          comment: comment?.trim().isEmpty == true ? null : comment?.trim(),
          updatedAt: DateTime.now(),
        ),
      );
      Get.snackbar('Success', 'Review updated successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update review');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteReview(ReviewModel review) async {
    try {
      await _repository.deleteReview(review.id, review.reviewedUserId);
      reviews.removeWhere((r) => r.id == review.id);
      Get.snackbar('Success', 'Review deleted');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete review');
      return false;
    }
  }

  /// Returns pending review opportunities for the current user.
  Future<List<ReviewOpportunity>> getPendingReviewOpportunities(
    List<FoodRequestModel> requests, {
    required bool isDonorView,
  }) async {
    final user = _authController.userModel.value;
    if (user == null) return [];

    final opportunities = <ReviewOpportunity>[];
    for (final request in requests.where((r) => r.status == 'Completed')) {
      if (request.postType == 'Sale') {
        if (!isDonorView && request.requesterId == user.uid) {
          final existing = await _repository.getReviewForRequest(
            request.id,
            user.uid,
          );
          if (existing == null) {
            opportunities.add(ReviewOpportunity(
              request: request,
              reviewedUserId: request.donorId,
              reviewedUserName: 'Seller',
              type: ReviewType.buyerToSeller,
            ));
          }
        }
      } else {
        if (isDonorView && request.donorId == user.uid) {
          final existing = await _repository.getReviewForRequest(
            request.id,
            user.uid,
          );
          if (existing == null) {
            opportunities.add(ReviewOpportunity(
              request: request,
              reviewedUserId: request.requesterId,
              reviewedUserName: request.requesterName,
              type: ReviewType.donorToVolunteer,
            ));
          }
        } else if (!isDonorView && request.requesterId == user.uid) {
          final existing = await _repository.getReviewForRequest(
            request.id,
            user.uid,
          );
          if (existing == null) {
            opportunities.add(ReviewOpportunity(
              request: request,
              reviewedUserId: request.donorId,
              reviewedUserName: 'Donor',
              type: ReviewType.volunteerToDonor,
            ));
          }
        }
      }
    }
    return opportunities;
  }
}

class ReviewOpportunity {
  final FoodRequestModel request;
  final String reviewedUserId;
  final String reviewedUserName;
  final ReviewType type;

  ReviewOpportunity({
    required this.request,
    required this.reviewedUserId,
    required this.reviewedUserName,
    required this.type,
  });
}
