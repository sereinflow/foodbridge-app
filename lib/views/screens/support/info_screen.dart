import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/support_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:get/get.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final String type;

  const InfoScreen({super.key, required this.title, required this.type});

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.isRegistered<SupportController>()
        ? Get.find<SupportController>()
        : Get.put(SupportController());

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoadingContent.value) {
          return const Center(child: CircularProgressIndicator());
        }

        String content = type == 'terms'
            ? controller.termsContent.value
            : controller.aboutContent.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.white,
            ),
          ),
        );
      }),
    );
  }
}
