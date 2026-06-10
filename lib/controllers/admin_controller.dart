import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_bridge/data/stats_repository.dart';
import 'package:food_bridge/models/campaign_model.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/models/food_request_model.dart';
import 'package:food_bridge/models/user_stats.dart';
import 'package:get/get.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var allFoodPosts = <FoodPostModel>[].obs;
  var allCampaigns = <CampaignModel>[].obs;
  var allUsers = <Map<String, dynamic>>[].obs;
  var allFeedback = <Map<String, dynamic>>[].obs;
  var allRequests = <FoodRequestModel>[].obs;

  var isLoading = false.obs;
  var isAnalyticsLoading = false.obs;
  final analytics = Rxn<AdminAnalytics>();
  final StatsRepository _statsRepository = StatsRepository();

  var totalUsers = 0.obs;
  var totalPosts = 0.obs;
  var totalCompletedPosts = 0.obs;
  var totalAvailablePosts = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchAnalytics() async {
    try {
      isAnalyticsLoading.value = true;
      analytics.value = await _statsRepository.getAdminAnalytics();
    } finally {
      isAnalyticsLoading.value = false;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchAllPosts(),
        fetchAllUsers(),
        fetchAllFeedback(),
        fetchAllRequests()
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllPosts() async {
    final foodPostsSnapshot = await _firestore.collection('food_posts').get();
    final campaignsSnapshot = await _firestore.collection('campaigns').get();

    allFoodPosts.value = foodPostsSnapshot.docs
        .map((doc) => FoodPostModel.fromMap(doc.data(), doc.id))
        .toList();

    allCampaigns.value = campaignsSnapshot.docs
        .map((doc) => CampaignModel.fromMap(doc.data(), doc.id))
        .toList();

    totalPosts.value = allFoodPosts.length + allCampaigns.length;
    totalCompletedPosts.value = allFoodPosts.where((post) => post.status == 'Completed' || post.status == 'Claimed' || post.status == 'Sold').length;
    totalAvailablePosts.value = allFoodPosts.where((post) => post.status == 'Available').length;
  }

  Future<void> fetchAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    allUsers.value = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
    totalUsers.value = allUsers.length;
  }

  Future<void> fetchAllRequests() async {
    final snapshot = await _firestore.collection('food_requests').orderBy('createdAt', descending: true).get();
    allRequests.value = snapshot.docs
        .map((doc) => FoodRequestModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> fetchAllFeedback() async {
    final snapshot = await _firestore
        .collection('feedback')
        .orderBy('createdAt', descending: true)
        .get();
    allFeedback.value = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  Future<void> deleteFoodPost(String postId) async {
    try {
      await _firestore.collection('food_posts').doc(postId).delete();
      Get.snackbar("Success", "Post deleted successfully");
      fetchAllPosts();
    } catch (e) {
      Get.snackbar("Error", "Failed to delete post: $e");
    }
  }

  Future<void> updateFoodPostStatus(String postId, String status) async {
    try {
      await _firestore.collection('food_posts').doc(postId).update({
        'status': status,
      });
      Get.snackbar("Success", "Status updated successfully");
      fetchAllPosts();
    } catch (e) {
      Get.snackbar("Error", "Failed to update status: $e");
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _firestore.collection('campaigns').doc(campaignId).delete();
      Get.snackbar("Success", "Campaign deleted successfully");
      fetchAllPosts();
    } catch (e) {
      Get.snackbar("Error", "Failed to delete campaign: $e");
    }
  }

  Future<void> updateContent(String type, String content) async {
    try {
      await _firestore.collection('app_content').doc(type).set({
        'text': content,
      });
      Get.snackbar("Success", "Content updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update content: $e");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      Get.snackbar("Success", "User deleted successfully");
      fetchAllUsers();
    } catch (e) {
      Get.snackbar("Error", "Failed to delete user: $e");
    }
  }
}
