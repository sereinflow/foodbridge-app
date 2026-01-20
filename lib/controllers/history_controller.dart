import 'package:flutter/material.dart';
import 'package:food_bridge/data/post_repository.dart';
import 'package:food_bridge/models/campaign_model.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final PostRepository _repository = PostRepository();
  var myFoodPosts = <FoodPostModel>[].obs;
  var myCampaigns = <CampaignModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyPosts();
  }

  Future<void> fetchMyPosts() async {
    try {
      isLoading.value = true;

      final allPosts = await _repository.getAllMyPosts();

      myFoodPosts.clear();
      myCampaigns.clear();

      for (var post in allPosts) {
        if (post is FoodPostModel) {
          myFoodPosts.add(post);
        } else if (post is CampaignModel) {
          myCampaigns.add(post);
        }
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
