import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/support_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:food_bridge/views/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.put(SupportController());
    final Color shadowLight = Colors.green.shade200;
    final Color shadowDark = Colors.green.shade200;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text("Help & FAQ", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Have questions or suggestions? Send us a message!",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: controller.nameController,
              icon: Icons.person,
              hint: "Your Name",
              bgColor: Colors.white,
              shadowLight: shadowLight,
              shadowDark: shadowDark,
              textColor: Colors.black,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: controller.emailController,
              icon: Icons.email,
              hint: "Your Email",
              bgColor: Colors.white,
              shadowLight: shadowLight,
              shadowDark: shadowDark,
              textColor: Colors.black,
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: controller.messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Your Message",
                  hintStyle: TextStyle(color: Colors.grey),
                  icon: Icon(Icons.message, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Obx(
              () => CustomBWButton(
                isLoading: controller.isSending.value,
                title: "Send Message",
                bgColor: AppColors.white,
                textColor: AppColors.primary,
                onTap: controller.submitFeedback,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
