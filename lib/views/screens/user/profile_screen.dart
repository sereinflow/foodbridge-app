import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/controllers/profile_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:food_bridge/views/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(controller.isEditing.value ? Icons.close : Icons.edit),
              onPressed: controller.toggleEdit,
            ),
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.userModel.value;
        if (user == null) return const Center(child: Text("User not found"));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(user.email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              if (controller.isEditing.value) ...[
                CustomTextField(
                  controller: controller.nameController,
                  icon: Icons.person,
                  hint: "Full Name",
                  bgColor: Colors.white,
                  shadowLight: Colors.white,
                  shadowDark: Colors.grey.shade200,
                  textColor: Colors.black,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: controller.phoneController,
                  icon: Icons.phone,
                  hint: "Phone Number",
                  bgColor: Colors.white,
                  shadowLight: Colors.white,
                  shadowDark: Colors.grey.shade200,
                  textColor: Colors.black,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: controller.bioController,
                  icon: Icons.info_outline,
                  hint: "Bio / Address",
                  bgColor: Colors.white,
                  shadowLight: Colors.white,
                  shadowDark: Colors.grey.shade200,
                  textColor: Colors.black,
                ),
                const SizedBox(height: 30),
                CustomBWButton(
                  isLoading: controller.isLoading.value,
                  title: "Save Changes",
                  bgColor: AppColors.primary,
                  shadowLight: Colors.white,
                  shadowDark: Colors.grey.shade300,
                  textColor: Colors.white,
                  onTap: controller.updateProfile,
                ),
              ] else ...[
                _buildInfoTile(Icons.person, "Name", user.name),
                _buildInfoTile(
                  Icons.phone,
                  "Phone",
                  (user.phone?.isNotEmpty ?? false) ? user.phone! : "Not set",
                ),
                _buildInfoTile(
                  Icons.info,
                  "Bio",
                  (user.bio?.isNotEmpty ?? false) ? user.bio! : "No bio",
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
