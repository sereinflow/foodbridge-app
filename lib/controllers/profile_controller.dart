import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/data/review_repository.dart';
import 'package:food_bridge/models/campaign_model.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/models/food_request_model.dart';
import 'package:food_bridge/models/review_model.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ReviewRepository _reviewRepository = ReviewRepository();

  // Form Controllers
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController bioController;

  var isLoading = false.obs;
  var isEditing = false.obs;

  // Role-specific lists
  var donationHistory = <FoodPostModel>[].obs;
  var purchaseHistory = <FoodRequestModel>[].obs;
  var ngoCampaigns = <CampaignModel>[].obs;
  var savedListings = <FoodPostModel>[].obs;
  var userReviews = <ReviewModel>[].obs;
  var isRoleDataLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final user = _authController.userModel.value;
    nameController = TextEditingController(text: user?.name ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');
    fetchRoleData();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.onClose();
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }

  Future<void> fetchRoleData() async {
    final user = _authController.userModel.value;
    if (user == null) return;

    try {
      isRoleDataLoading.value = true;

      // Always load reviews
      final reviews = await _reviewRepository.getReviewsForUser(user.uid);
      userReviews.value = reviews;

      final role = user.role.toLowerCase();
      if (role == 'donor') {
        final snap = await _firestore
            .collection('food_posts')
            .where('userId', isEqualTo: user.uid)
            .get();
        donationHistory.value = snap.docs
            .map((doc) => FoodPostModel.fromMap(doc.data(), doc.id))
            .toList();
      } else if (role == 'buyer') {
        final snap = await _firestore
            .collection('food_requests')
            .where('requesterId', isEqualTo: user.uid)
            .get();
        purchaseHistory.value = snap.docs
            .map((doc) => FoodRequestModel.fromMap(doc.data(), doc.id))
            .toList();

        // Load saved listings (favorites)
        if (user.savedPosts.isNotEmpty) {
          final chunk = user.savedPosts.take(10).toList();
          final postsSnap = await _firestore
              .collection('food_posts')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          savedListings.value = postsSnap.docs
              .map((doc) => FoodPostModel.fromMap(doc.data(), doc.id))
              .toList();
        } else {
          savedListings.clear();
        }
      } else if (role == 'ngo') {
        final snap = await _firestore
            .collection('campaigns')
            .where('userId', isEqualTo: user.uid)
            .get();
        ngoCampaigns.value = snap.docs
            .map((doc) => CampaignModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      debugPrint("Error fetching profile role data: $e");
    } finally {
      isRoleDataLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      String uid = _authController.userModel.value!.uid;

      Map<String, dynamic> updates = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'bio': bioController.text.trim(),
      };

      await _firestore.collection('users').doc(uid).update(updates);

      // Update local User Model
      _authController.userModel.value = _authController.userModel.value
          ?.copyWith(
            name: updates['name'],
            phone: updates['phone'],
            bio: updates['bio'],
          );

      isEditing.value = false;
      Get.snackbar("success".tr, "Profile updated successfully");
      fetchRoleData();
    } catch (e) {
      Get.snackbar("error".tr, "Failed to update profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
