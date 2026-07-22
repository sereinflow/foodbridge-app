import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:food_bridge/views/widgets/custom_textfield.dart';
import 'package:food_bridge/views/screens/admin/admin_dashboard_screen.dart';
import 'package:food_bridge/views/screens/auth/forgot_password.dart';
import 'package:food_bridge/views/screens/auth/signup_screen.dart';
import 'package:food_bridge/views/screens/user/main_layout_screen.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final textColor = AppColors.textPrimary;
    final shadowLight = Get.isDarkMode ? Colors.black12 : Colors.white.withValues(alpha: 0.9);
    final shadowDark = Get.isDarkMode ? Colors.black26 : Colors.black.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: shadowLight,
                          offset: const Offset(-6, -6),
                          blurRadius: 12,
                        ),
                        BoxShadow(
                          color: shadowDark,
                          offset: const Offset(6, 6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'login_welcome'.tr,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'login_subtitle'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(height: 30),

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

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.to(() => ForgotPasswordPage());
                      },
                      child: Text(
                        'forgot_password'.tr,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Obx(
                    () => CustomBWButton(
                      isLoading: authController.isLoading.value,
                      title: 'login'.tr,
                      bgColor: AppColors.background,
                      shadowLight: shadowLight,
                      shadowDark: shadowDark,
                      textColor: textColor,
                      onTap: () async {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          Get.snackbar(
                            'error'.tr,
                            "Please fill in all fields",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        String? isOkay = await authController.login(
                          email,
                          password,
                        );

                        if (isOkay != null && isOkay != "error") {
                          Get.snackbar(
                            'success'.tr,
                            "Logged in successfully",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          if (isOkay == "admin") {
                            Get.offAll(() => const AdminDashboardScreen());
                          } else {
                            Get.offAll(() => MainLayoutScreen());
                          }
                        } else {
                          Get.snackbar(
                            'error'.tr,
                            "Login failed. Please check your credentials.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'dont_have_acc'.tr,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => SignupScreen());
                        },
                        child: Text(
                          'register'.tr,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
