import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/admin_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/widgets/custom_confirmation_dialog.dart';
import 'package:get/get.dart';

class AdminPostsScreen extends StatelessWidget {
  const AdminPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Manage Posts",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: const TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: "Food Posts"),
                    Tab(text: "Campaigns"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFoodPostsList(controller),
                    _buildCampaignsList(controller),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFoodPostsList(AdminController controller) {
    if (controller.allFoodPosts.isEmpty) {
      return const Center(child: Text("No food posts available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.allFoodPosts.length,
      itemBuilder: (context, index) {
        final post = controller.allFoodPosts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                post.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            title: Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: post.type == 'Free'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        post.type,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: post.type == 'Free'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (post.status == 'Claimed' &&
                        post.claimerContact != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        "(${post.claimerContact})",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  onSelected: (newStatus) =>
                      controller.updateFoodPostStatus(post.id, newStatus),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Available',
                      child: Text('Mark as Available'),
                    ),
                    const PopupMenuItem(
                      value: 'Claimed',
                      child: Text('Mark as Claimed'),
                    ),
                    const PopupMenuItem(
                      value: 'Sold',
                      child: Text('Mark as Sold'),
                    ),
                  ],
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    CustomConfirmationDialog.show(
                      title: "Delete Post",
                      message: "Are you sure you want to delete this post?",
                      onConfirm: () {
                        Get.back();
                        controller.deleteFoodPost(post.id);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCampaignsList(AdminController controller) {
    if (controller.allCampaigns.isEmpty) {
      return const Center(child: Text("No campaigns available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.allCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = controller.allCampaigns[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                campaign.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            title: Text(
              campaign.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Raised: BDT ${campaign.raised.toStringAsFixed(0)} / BDT ${campaign.target.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: () {
                CustomConfirmationDialog.show(
                  title: "Delete Campaign",
                  message: "Are you sure you want to delete this campaign?",
                  onConfirm: () {
                    Get.back();
                    controller.deleteCampaign(campaign.id);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
