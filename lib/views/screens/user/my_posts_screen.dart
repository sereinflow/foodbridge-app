import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/controllers/home_controller.dart';
import 'package:food_bridge/data/post_repository.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/screens/post/create_post_screen.dart';
import 'package:food_bridge/views/screens/user/food_post_details_screen.dart';
import 'package:food_bridge/views/screens/user/post_requests_screen.dart';
import 'package:food_bridge/views/widgets/custom_confirmation_dialog.dart';
import 'package:food_bridge/views/widgets/empty_state_widget.dart';
import 'package:food_bridge/views/widgets/loading_state_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<FoodPostModel> _allPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchMyPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMyPosts() async {
    setState(() => _isLoading = true);
    try {
      final userId = Get.find<AuthController>().userModel.value?.uid ?? '';
      final snapshot = await FirebaseFirestore.instance
          .collection('food_posts')
          .where('userId', isEqualTo: userId)
          .get();

      final posts = snapshot.docs.map((doc) => FoodPostModel.fromMap(doc.data(), doc.id)).toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _allPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load posts: $e");
      setState(() => _isLoading = false);
    }
  }

  List<FoodPostModel> _getFilteredPosts(int tabIndex) {
    switch (tabIndex) {
      case 0: // All
        return _allPosts;
      case 1: // Donations
        return _allPosts.where((p) => p.type == 'Free').toList();
      case 2: // Resale
        return _allPosts.where((p) => p.type == 'Sale').toList();
      case 3: // Active
        return _allPosts.where((p) => p.status == 'Available' || p.status == 'Reserved').toList();
      case 4: // Completed
        return _allPosts.where((p) => p.status == 'Completed' || p.status == 'Claimed' || p.status == 'Sold').toList();
      default:
        return _allPosts;
    }
  }

  Future<void> _deletePost(FoodPostModel post) async {
    // 1. Check if orders exist for this post
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('foodPostId', isEqualTo: post.id)
        .get();
    
    // 2. Check if requests exist for this post
    final requestsSnapshot = await FirebaseFirestore.instance
        .collection('food_requests')
        .where('postId', isEqualTo: post.id)
        .get();

    final hasActiveOrders = ordersSnapshot.docs.any((doc) => doc.data()['orderStatus'] != 'Cancelled');
    final hasActiveRequests = requestsSnapshot.docs.any((doc) => doc.data()['status'] != 'Rejected' && doc.data()['status'] != 'Cancelled');

    if (hasActiveOrders || hasActiveRequests || post.status == 'Reserved') {
      Get.defaultDialog(
        title: "Cannot Delete",
        middleText: "This post cannot be deleted because it already has active requests.",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primary,
        onConfirm: () => Get.back(),
      );
      return;
    }

    CustomConfirmationDialog.show(
      title: "Delete Listing",
      message: "Are you sure you want to delete this food listing permanently?",
      onConfirm: () async {
        Get.back(); // Close dialog
        setState(() => _isLoading = true);
        try {
          await PostRepository().deleteFoodPost(post.id);
          Get.snackbar("Success", "Listing deleted successfully.");
          _fetchMyPosts();
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchData();
          }
        } catch (e) {
          Get.snackbar("Error", "Failed to delete post: $e");
          setState(() => _isLoading = false);
        }
      },
    );
  }

  Future<void> _updatePostStatus(String postId, String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await PostRepository().updateFoodPostStatus(postId, newStatus);
      Get.snackbar("Success", "Listing status updated to $newStatus.");
      _fetchMyPosts();
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchData();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update status: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Posts", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Donations"),
            Tab(text: "Resale"),
            Tab(text: "Active"),
            Tab(text: "Completed"),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: _isLoading
          ? const LoadingStateWidget()
          : TabBarView(
              controller: _tabController,
              children: List.generate(5, (index) {
                final posts = _getFilteredPosts(index);
                if (posts.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.post_add_outlined,
                    title: "No Posts Found",
                    subtitle: "No posts found in this tab.",
                  );
                }
                return ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: posts.length,
                  itemBuilder: (context, idx) {
                    final post = posts[idx];
                    return _buildPostCard(post);
                  },
                );
              }),
            ),
    );
  }

  Widget _buildPostCard(FoodPostModel post) {
    final formattedDate = DateFormat('dd MMM yyyy').format(post.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.surfaceMuted,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.title, style: AppTypography.titleMedium),
                      const SizedBox(height: 4),
                      Text("Qty: ${post.quantity}", style: AppTypography.bodySmall),
                      const SizedBox(height: 4),
                      Text(formattedDate, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTypeBadge(post.type),
                    const SizedBox(height: 6),
                    _buildStatusBadge(post.status),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 20, color: Colors.grey),
                      tooltip: "View Details",
                      onPressed: () => Get.to(() => FoodPostDetailsScreen(post: post)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                      tooltip: "Edit",
                      onPressed: () => Get.to(() => CreatePostScreen(existingPost: post))?.then((_) => _fetchMyPosts()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      tooltip: "Delete",
                      onPressed: () => _deletePost(post),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20, color: Colors.grey),
                      tooltip: "Share",
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: "Check out this food listing: ${post.title} on FoodBridge!"));
                        Get.snackbar("Shared", "Listing details copied to clipboard!");
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.to(() => PostRequestsScreen(
                            postId: post.id,
                            postTitle: post.title,
                          )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: const Text("Requests", style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      onSelected: (newStatus) => _updatePostStatus(post.id, newStatus),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'Available', child: Text("Available")),
                        const PopupMenuItem(value: 'Reserved', child: Text("Reserved")),
                        const PopupMenuItem(value: 'Completed', child: Text("Completed")),
                        const PopupMenuItem(value: 'Cancelled', child: Text("Cancelled")),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.more_vert, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final isFree = type == 'Free';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isFree ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isFree ? Colors.green.shade200 : Colors.orange.shade200),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: isFree ? Colors.green.shade700 : Colors.orange.shade700,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'available':
        color = Colors.green;
      case 'reserved':
        color = Colors.amber;
      case 'completed':
      case 'sold':
        color = Colors.blue;
      case 'cancelled':
        color = Colors.red;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
