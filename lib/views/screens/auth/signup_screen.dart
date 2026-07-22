import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:food_bridge/views/screens/user/main_layout_screen.dart';
import 'package:get/get.dart';
import '../../widgets/custom_textfield.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final authController = Get.find<AuthController>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final selectedRole = 'donor'.obs;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textPrimary;
    final shadowLight = Get.isDarkMode ? Colors.black12 : Colors.white.withValues(alpha: 0.9);
    final shadowDark = Get.isDarkMode ? Colors.black26 : Colors.black.withValues(alpha: 0.12);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.primary),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'create_account'.tr,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'register_subtitle'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(height: 30),

                  CustomTextField(
                    controller: nameController,
                    icon: Icons.person_outline,
                    hint: 'fullname_hint'.tr,
                    bgColor: AppColors.background,
                    shadowLight: shadowLight,
                    shadowDark: shadowDark,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: emailController,
                    icon: Icons.email_outlined,
                    hint: 'email_hint'.tr,
                    bgColor: AppColors.background,
                    shadowLight: shadowLight,
                    shadowDark: shadowDark,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 20),

                  CustomPasswordField(
                    controller: passwordController,
                    icon: Icons.lock_outline,
                    hint: 'password_hint'.tr,
                    bgColor: AppColors.background,
                    shadowLight: shadowLight,
                    shadowDark: shadowDark,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 20),

                  CustomPasswordField(
                    controller: confirmPasswordController,
                    icon: Icons.lock_outline,
                    hint: 'confirm_password_hint'.tr,
                    bgColor: AppColors.background,
                    shadowLight: shadowLight,
                    shadowDark: shadowDark,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 20),

                  // Role Selection Dropdown
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: shadowDark,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            value: selectedRole.value,
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                            decoration: InputDecoration(
                              icon: const Icon(Icons.assignment_ind_outlined, color: AppColors.primary),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              labelText: 'role_select'.tr,
                              labelStyle: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 14),
                            ),
                            dropdownColor: AppColors.card,
                            style: TextStyle(color: textColor, fontSize: 16),
                            items: [
                              DropdownMenuItem(value: 'donor', child: Text('donor'.tr)),
                              DropdownMenuItem(value: 'volunteer', child: Text('volunteer'.tr)),
                              DropdownMenuItem(value: 'ngo', child: Text('ngo'.tr)),
                              DropdownMenuItem(value: 'buyer', child: Text('buyer'.tr)),
                            ],
                            onChanged: (val) {
                              if (val != null) selectedRole.value = val;
                            },
                          ),
                        ),
                      )),

                  const SizedBox(height: 30),

                  Obx(
                    () => CustomBWButton(
                      isLoading: authController.isLoading.value,
                      title: 'register'.tr,
                      bgColor: AppColors.background,
                      shadowLight: shadowLight,
                      shadowDark: shadowDark,
                      textColor: textColor,
                      onTap: () async {
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();
                        final confirmPassword = confirmPasswordController.text
                            .trim();

                        if (name.isEmpty ||
                            email.isEmpty ||
                            password.isEmpty ||
                            confirmPassword.isEmpty) {
                          Get.snackbar(
                            'error'.tr,
                            "Please fill in all fields",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (password != confirmPassword) {
                          Get.snackbar(
                            'error'.tr,
                            "Passwords do not match",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        bool isRegistered = await authController.register(
                          email,
                          password,
                          name,
                          selectedRole.value,
                        );
                        if (isRegistered) {
                          Get.offAll(() => MainLayoutScreen());
                        } else {
                          Get.snackbar('error'.tr, "Please try again!");
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Get.back(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'already_have_acc'.tr,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          'login'.tr,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
