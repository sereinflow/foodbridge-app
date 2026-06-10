import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_bridge/models/review_model.dart';
import 'package:uuid/uuid.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<ReviewModel?> getReviewForRequest(
    String requestId,
    String reviewerId,
  ) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('requestId', isEqualTo: requestId)
        .where('reviewerId', isEqualTo: reviewerId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return ReviewModel.fromMap(doc.data(), doc.id);
  }

  Future<List<ReviewModel>> getReviewsForUser(String userId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('reviewerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> submitReview(ReviewModel review) async {
    final existing = await getReviewForRequest(
      review.requestId,
      review.reviewerId,
    );
    if (existing != null) {
      throw Exception('You have already reviewed this transaction.');
    }

    final id = review.id.isNotEmpty ? review.id : _uuid.v4();
    await _firestore.collection('reviews').doc(id).set(review.toMap());
    await _recalculateUserRating(review.reviewedUserId);
  }

  Future<void> updateReview(ReviewModel review) async {
    await _firestore.collection('reviews').doc(review.id).update({
      'rating': review.rating,
      'comment': review.comment,
      'updatedAt': Timestamp.now(),
    });
    await _recalculateUserRating(review.reviewedUserId);
  }

  Future<void> deleteReview(String reviewId, String reviewedUserId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
    await _recalculateUserRating(reviewedUserId);
  }

  Future<void> _recalculateUserRating(String userId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) {
      await _firestore.collection('users').doc(userId).update({
        'averageRating': 0.0,
        'reviewCount': 0,
      });
      return;
    }

    double total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['rating'] as num?)?.toDouble() ?? 0;
    }
    final count = snapshot.docs.length;
    final average = total / count;

    await _firestore.collection('users').doc(userId).update({
      'averageRating': double.parse(average.toStringAsFixed(2)),
      'reviewCount': count,
    });
  }
}
