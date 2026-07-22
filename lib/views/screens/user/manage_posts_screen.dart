import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/history_controller.dart';
import 'package:food_bridge/data/post_repository.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/screens/user/post_requests_screen.dart';
import 'package:get/get.dart';

class ManagePostsScreen extends StatelessWidget {
  const ManagePostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.put(HistoryController());
    final PostRepository repository = PostRepository();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Manage My Posts",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myFoodPosts.isEmpty) {
          return const Center(
            child: Text("You haven't posted any food shares yet."),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: controller.myFoodPosts.length,
          itemBuilder: (context, index) {
            final post = controller.myFoodPosts[index];
            return _buildPostCard(post, repository, controller);
          },
        );
      }),
    );
  }

  Widget _buildPostCard(
    FoodPostModel post,
    PostRepository repository,
    HistoryController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              title: Text(
                post.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${post.type} • ${post.status}"),
              trailing: PopupMenuButton<String>(
                onSelected: (newStatus) async {
                  await repository.updateFoodPostStatus(post.id, newStatus);
                  controller.fetchMyPosts(); // Refresh
                  Get.snackbar("Updated", "Status changed to $newStatus");
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'Available',
                    child: Text('Mark as Available'),
                  ),
                  const PopupMenuItem(
                    value: 'Reserved',
                    child: Text('Mark as Reserved'),
                  ),
                  const PopupMenuItem(
                    value: 'Sold',
                    child: Text('Mark as Sold'),
                  ),
                  const PopupMenuItem(
                    value: 'Expired',
                    child: Text('Mark as Expired'),
                  ),
                  const PopupMenuItem(
                    value: 'Completed',
                    child: Text('Mark as Completed'),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Change",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
            const Divider(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(
                    () => PostRequestsScreen(
                      postId: post.id,
                      postTitle: post.title,
                    ),
                  );
                },
                icon: const Icon(Icons.people_outline, size: 18),
                label: const Text("View All Requests"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
