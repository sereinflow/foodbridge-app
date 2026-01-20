import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/history_controller.dart';
import 'package:food_bridge/models/campaign_model.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:get/get.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.put(HistoryController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: const Text(
            "My History",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: AppColors.white,
            tabs: [
              Tab(text: "Food Shares"),
              Tab(text: "Campaigns"),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              _buildFoodList(controller.myFoodPosts),
              _buildCampaignList(controller.myCampaigns),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFoodList(List<FoodPostModel> posts) {
    if (posts.isEmpty) {
      return _buildEmptyState("No food posts yet.");
    }
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            onTap: () {
              Get.defaultDialog(
                title: post.title,
                content: Column(
                  children: [
                    Image.network(
                      post.imageUrl,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text("Status: ${post.status}"),
                    if (post.status == 'Claimed' && post.claimedBy != null)
                      Text(
                        "Claimed by user ID: ${post.claimedBy}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 10),
                    Text("Quantity: ${post.quantity}"),
                  ],
                ),
                textConfirm: "OK",
                confirmTextColor: Colors.white,
                onConfirm: () => Get.back(),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            title: Text(
              post.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${post.quantity} • ${post.status}"),
                if (post.status == 'Claimed')
                  const Text(
                    "Item has been requested!",
                    style: TextStyle(color: AppColors.primary, fontSize: 10),
                  ),
              ],
            ),
            trailing: Chip(
              label: Text(
                post.type,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              backgroundColor: post.type == 'Free'
                  ? AppColors.primary
                  : Colors.orange,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCampaignList(List<CampaignModel> campaigns) {
    if (campaigns.isEmpty) {
      return _buildEmptyState("No campaigns created.");
    }
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    campaign.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                title: Text(
                  campaign.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  "Target: BDT ${campaign.target} • Raised: BDT ${campaign.raised}",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: LinearProgressIndicator(
                  value:
                      campaign.raised /
                      (campaign.target > 0 ? campaign.target : 1),
                  color: AppColors.primary,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
