import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_bridge/models/campaign_model.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/models/food_request_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> createFoodPost(FoodPostModel post) async {
    await _firestore.collection('food_posts').doc(post.id).set(post.toMap());
  }

  Future<void> createCampaign(CampaignModel campaign) async {
    await _firestore
        .collection('campaigns')
        .doc(campaign.id)
        .set(campaign.toMap());
  }

  Future<List<FoodPostModel>> getFoodPosts() async {
    final snapshot = await _firestore
        .collection('food_posts')
        .where('status', isEqualTo: 'Available')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => FoodPostModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<CampaignModel>> getCampaigns() async {
    final snapshot = await _firestore.collection('campaigns').get();
    return snapshot.docs
        .map((doc) => CampaignModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<dynamic>> getAllMyPosts() async {
    final uid = currentUserId;
    if (uid.isEmpty) return [];

    final foodPostsFuture = _firestore
        .collection('food_posts')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    final campaignsFuture = _firestore
        .collection('campaigns')
        .where('userId', isEqualTo: uid)
        .get();

    final results = await Future.wait([foodPostsFuture, campaignsFuture]);

    final foodPosts = results[0].docs
        .map((doc) => FoodPostModel.fromMap(doc.data(), doc.id))
        .toList();
    final campaigns = results[1].docs
        .map((doc) => CampaignModel.fromMap(doc.data(), doc.id))
        .toList();

    return [...foodPosts, ...campaigns];
  }

  Future<List<FoodPostModel>> searchFoodPosts(String query) async {
    final all = await getFoodPosts();
    final q = query.toLowerCase();
    return all
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q) ||
              p.pickupLocation.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> donateToCampaign(String campaignId, double amount) async {
    final docRef = _firestore.collection('campaigns').doc(campaignId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Campaign does not exist!");

      final newRaised = (snapshot.data()?['raised'] ?? 0.0) + amount;
      final newDonors = (snapshot.data()?['donors'] ?? 0) + 1;

      transaction.update(docRef, {'raised': newRaised, 'donors': newDonors});
    });
  }

  Future<void> createFoodRequest(FoodRequestModel request) async {
    await _firestore
        .collection('food_requests')
        .doc(request.id)
        .set(request.toMap());
  }

  Future<List<FoodRequestModel>> getMyRequests() async {
    final uid = currentUserId;
    if (uid.isEmpty) return [];

    final snapshot = await _firestore
        .collection('food_requests')
        .where('requesterId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FoodRequestModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<FoodRequestModel>> getRequestsForPost(String postId) async {
    final snapshot = await _firestore
        .collection('food_requests')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FoodRequestModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    await _firestore.collection('food_requests').doc(requestId).update({
      'status': newStatus,
    });
  }

  // Deprecated: logic moved to requests
  Future<void> collectFoodPost(String postId) async {
    final uid = currentUserId;
    if (uid.isEmpty) return;

    await _firestore.collection('food_posts').doc(postId).update({
      'status': 'Claimed',
      'claimedBy': uid,
    });
  }

  // Deprecated: logic moved to requests
  Future<void> collectFoodPostWithContact(String postId, String contact) async {
    final uid = currentUserId;
    if (uid.isEmpty) return;

    await _firestore.collection('food_posts').doc(postId).update({
      'status': 'Claimed',
      'claimedBy': uid,
      'claimerContact': contact,
    });
  }

  Future<void> updateFoodPostStatus(String postId, String newStatus) async {
    await _firestore.collection('food_posts').doc(postId).update({
      'status': newStatus,
    });
  }
}
