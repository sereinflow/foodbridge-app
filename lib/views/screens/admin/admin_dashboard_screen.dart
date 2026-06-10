import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/admin_controller.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/widgets/custom_confirmation_dialog.dart';
import 'package:food_bridge/views/widgets/interactive_card.dart';
import 'package:food_bridge/views/screens/admin/admin_posts_screen.dart';
import 'package:food_bridge/views/screens/admin/admin_users_screen.dart';
import 'package:food_bridge/views/screens/admin/admin_content_screen.dart';
import 'package:food_bridge/views/screens/admin/admin_feedback_screen.dart';
import 'package:food_bridge/views/screens/admin/admin_requests_screen.dart';
import 'package:food_bridge/views/screens/admin/admin_analytics_screen.dart';
import 'package:get/get.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.put(AdminController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildHeader(authController),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Total Users",
                            controller.totalUsers.value.toString(),
                            Icons.people_alt_outlined,
                            AppColors.primary,
                            () => Get.to(() => const AdminUsersScreen()),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            "Total Posts",
                            controller.totalPosts.value.toString(),
                            Icons.article_outlined,
                            Colors.orange,
                            () => Get.to(() => const AdminPostsScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Completed",
                            controller.totalCompletedPosts.value.toString(),
                            Icons.check_circle_outline,
                            Colors.green,
                            () => Get.to(() => const AdminPostsScreen()),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            "Available",
                            controller.totalAvailablePosts.value.toString(),
                            Icons.food_bank_outlined,
                            Colors.blue,
                            () => Get.to(() => const AdminPostsScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.15,
                      children: [
                        _buildGridMenuItem(
                          title: 'Analytics',
                          subtitle: 'Trends & platform insights',
                          icon: Icons.analytics_outlined,
                          color: AppColors.primary,
                          onTap: () {
                            controller.fetchAnalytics();
                            Get.to(() => const AdminAnalyticsScreen());
                          },
                        ),
                        _buildGridMenuItem(
                          title: "Manage Posts",
                          subtitle: "View and delete posts",
                          icon: Icons.grid_view_rounded,
                          color: Colors.blue,
                          onTap: () => Get.to(() => const AdminPostsScreen()),
                        ),
                        _buildGridMenuItem(
                          title: "Requests",
                          subtitle: "Food requests status",
                          icon: Icons.assignment_turned_in_outlined,
                          color: Colors.indigo,
                          onTap: () => Get.to(() => const AdminRequestsScreen()),
                        ),
                        _buildGridMenuItem(
                          title: "Manage Users",
                          subtitle: "View registered users",
                          icon: Icons.group_outlined,
                          color: Colors.purple,
                          onTap: () => Get.to(() => const AdminUsersScreen()),
                        ),
                        _buildGridMenuItem(
                          title: "Content",
                          subtitle: "Terms & About Us editors",
                          icon: Icons.edit_note_rounded,
                          color: Colors.teal,
                          onTap: () => Get.to(() => const AdminContentScreen()),
                        ),
                        _buildGridMenuItem(
                          title: "Feedback",
                          subtitle: "View received messages",
                          icon: Icons.chat_bubble_outline_rounded,
                          color: Colors.amber.shade800,
                          onTap: () => Get.to(() => const AdminFeedbackScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(AuthController authController) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Admin Panel",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Welcome Back",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () {
                CustomConfirmationDialog.show(
                  title: "Logout",
                  message: "Are you sure you want to logout?",
                  onConfirm: () {
                    Get.back();
                    authController.logout();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InteractiveCard(
      onTap: onTap,
      color: Colors.white,
      activeColor: color.withValues(alpha: 0.06),
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InteractiveCard(
      onTap: onTap,
      color: Colors.white,
      activeColor: color.withValues(alpha: 0.06),
      borderRadius: 20,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
