import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/screens/user/profile_screen.dart';
import 'package:food_bridge/views/screens/user/history_screen.dart';
import 'package:food_bridge/views/screens/user/my_requests_screen.dart';
import 'package:food_bridge/views/screens/user/manage_posts_screen.dart';
import 'package:food_bridge/views/screens/support/help_screen.dart';
import 'package:food_bridge/views/screens/support/info_screen.dart';
import 'package:food_bridge/views/widgets/custom_confirmation_dialog.dart';
import 'package:get/get.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 50, left: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final user = authController.userModel.value;
            return _buildHeader(user?.name ?? "User", user?.email ?? "Email");
          }),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 30),
              children: [
                _buildMenuItem(
                  Icons.person_outline,
                  "Profile",
                  () => Get.to(() => const ProfileScreen()),
                ),
                _buildMenuItem(
                  Icons.history,
                  "Campaign History",
                  () => Get.to(() => const HistoryScreen()),
                ),
                _buildMenuItem(
                  Icons.shopping_bag_outlined,
                  "My Collections",
                  () => Get.to(() => const MyRequestsScreen()),
                ),
                _buildMenuItem(
                  Icons.event_available,
                  "My Posts Status",
                  () => Get.to(() => const ManagePostsScreen()),
                ),

                _buildMenuItem(
                  Icons.verified_user_outlined,
                  "Terms & Service",
                  () {
                    Get.to(
                      () => const InfoScreen(
                        title: "Terms & Service",
                        type: "terms",
                      ),
                    );
                  },
                ),
                _buildMenuItem(Icons.info_outline, "About Us", () {
                  Get.to(
                    () => const InfoScreen(title: "About Us", type: "about"),
                  );
                }),
                _buildMenuItem(Icons.help_outline, "Help & FAQ", () {
                  Get.to(() => const HelpScreen());
                }),
                _buildMenuItem(Icons.delete, "Delete Account", () {
                  CustomConfirmationDialog.show(
                    title: "Delete Account",
                    message:
                        "Are you sure you want to delete your account? This action cannot be undone and you will lose all your data.",
                    onConfirm: () {
                      Get.back();
                      authController.deleteAccount();
                    },
                  );
                }),
              ],
            ),
          ),
          _buildMenuItem(Icons.logout, "Logout", () {
            CustomConfirmationDialog.show(
              title: "Logout",
              message: "Are you sure you want to logout?",
              onConfirm: () {
                Get.back();
                authController.logout();
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String email) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "U",
            style: const TextStyle(
              fontSize: 24,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
