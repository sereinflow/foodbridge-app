import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/admin_controller.dart';
import 'package:food_bridge/controllers/support_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:get/get.dart';

class AdminContentScreen extends StatelessWidget {
  const AdminContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController adminController = Get.find<AdminController>();
    final SupportController supportController =
        Get.isRegistered<SupportController>()
        ? Get.find<SupportController>()
        : Get.put(SupportController());

    final termsController = TextEditingController();
    final aboutController = TextEditingController();

    termsController.text = supportController.termsContent.value;
    aboutController.text = supportController.aboutContent.value;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          "Manage Content",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildEditorSection(
              "Terms & Conditions",
              "Update your application's terms of service here.",
              termsController,
              () =>
                  adminController.updateContent('terms', termsController.text),
            ),
            const SizedBox(height: 30),
            _buildEditorSection(
              "About Us",
              "Share your organization's story and mission.",
              aboutController,
              () =>
                  adminController.updateContent('about', aboutController.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorSection(
    String title,
    String subtitle,
    TextEditingController controller,
    VoidCallback onSave,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: controller,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: "Enter content here...",
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(15),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
