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

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFF333333);
    final shadowLight = Colors.white.withValues(alpha: 0.9);
    final shadowDark = Colors.black.withValues(alpha: 0.12);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: AppColors.primary),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.9),
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
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Register to continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(height: 30),

                  CustomTextField(
                    controller: nameController,
                    icon: Icons.person_outline,
                    hint: 'Full Name',
                    bgColor: AppColors.white,
                    shadowLight: shadowLight,
                    shadowDark: shadowDark,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: emailController,
                    icon: Icons.email_outlined,
                    hint: 'E-Mail',
                    bgColor: AppColors.white,
                    shadowLight: shadowLight,
                    shadowDark: shadowDark,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 20),

                  CustomPasswordField(
                    controller: passwordController,
                    icon: Icons.lock_outline,
                    hint: 'Password',
                    bgColor: AppColors.white,
                    shadowLight: shadowLight,
                    shadowDark: shadowDark,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 20),

                  CustomPasswordField(
                    controller: confirmPasswordController,
                    icon: Icons.lock_outline,
                    hint: 'Confirm Password',
                    bgColor: AppColors.white,
                    shadowLight: shadowLight,
                    shadowDark: shadowDark,
                    textColor: textColor,
                  ),

                  const SizedBox(height: 30),

                  Obx(
                    () => CustomBWButton(
                      isLoading: authController.isLoading.value,
                      title: "Register",
                      bgColor: AppColors.white,
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
                            "Error",
                            "Please fill in all fields",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (password != confirmPassword) {
                          Get.snackbar(
                            "Error",
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
                        );
                        if (isRegistered) {
                          Get.offAll(() => MainLayoutScreen());
                        } else {
                          Get.snackbar("Error", "Please try again!");
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
                          "Already have an account? ",
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                          ),
                        ),
                        const Text(
                          "Login",
                          style: TextStyle(
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
