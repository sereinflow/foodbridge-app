import 'package:flutter/material.dart';
import 'package:food_bridge/data/post_repository.dart';
import 'package:food_bridge/models/campaign_model.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/models/food_request_model.dart';
import 'package:food_bridge/views/widgets/booking_form_dialog.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class HomeController extends GetxController {
  final PostRepository _repository = PostRepository();

  var campaigns = <CampaignModel>[].obs;
  var foodPosts = <FoodPostModel>[].obs;

  var filteredCampaigns = <CampaignModel>[].obs;
  var filteredFoodPosts = <FoodPostModel>[].obs;

  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var activeFilters = <String>[].obs;

  var filterType = 'All'.obs; // All, Free, Sale
  var filterExcludeExpired = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;

      final campaignsData = await _repository.getCampaigns();
      final foodPostsData = await _repository.getFoodPosts();

      campaigns.value = campaignsData;
      foodPosts.value = foodPostsData;

      filteredCampaigns.value = campaignsData;
      filteredFoodPosts.value = foodPostsData;
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFilter(String tag) {
    if (activeFilters.contains(tag)) {
      activeFilters.remove(tag);
    } else {
      activeFilters.add(tag);
    }
    _applyFilters();
  }

  void setFilterType(String type) {
    filterType.value = type;
    _applyFilters();
  }

  void toggleExcludeExpired() {
    filterExcludeExpired.value = !filterExcludeExpired.value;
    _applyFilters();
  }

  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    final q = searchQuery.value.toLowerCase();

    filteredCampaigns.value = campaigns.where((c) {
      if (q.isEmpty) return true;
      return c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.tag.toLowerCase().contains(q);
    }).toList();

    filteredFoodPosts.value = foodPosts.where((p) {
      final matchesQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.pickupLocation.toLowerCase().contains(q);

      final matchesTags = activeFilters.isEmpty ||
          activeFilters.every((tag) => p.tags.contains(tag));

      final matchesType = filterType.value == 'All' || p.type == filterType.value;

      bool isExpired = false;
      if (p.expiryDate != null) {
        isExpired = p.expiryDate!.isBefore(DateTime.now());
      }
      final matchesExpiry = !filterExcludeExpired.value || !isExpired;

      return matchesQuery && matchesTags && matchesType && matchesExpiry;
    }).toList();
  }

  Future<void> donate(String campaignId, double amount) async {
    try {
      await _repository.donateToCampaign(campaignId, amount);
      Get.snackbar("Success", "Thank you for the donation!");
      fetchData();
    } catch (e) {
      Get.snackbar("Error", "Failed to donate: $e");
    }
  }

  Future<void> collect(FoodPostModel post) async {
    BookingFormDialog.show(
      title: post.type == 'Free' ? "Collect Item" : "Buy Item",
      onSubmit: (name, phone, address) {
        _processCollection(post, name, phone, address);
      },
    );
  }

  Future<void> _processCollection(
    FoodPostModel post,
    String name,
    String phone,
    String address,
  ) async {
    try {
      final request = FoodRequestModel(
        id: const Uuid().v4(),
        postId: post.id,
        donorId: post.userId,
        requesterId: _repository.currentUserId,
        requesterName: name,
        requesterNumber: phone,
        requesterAddress: address,
        status: 'Pending',
        createdAt: DateTime.now(),
        postTitle: post.title,
        postImageUrl: post.imageUrl,
        postType: post.type,
      );

      await _repository.createFoodRequest(request);

      Get.snackbar(
        "Request Sent",
        "Your request to ${post.type == 'Free' ? 'collect' : 'buy'} this item has been sent to the donor.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to send request: $e");
    }
  }
}
