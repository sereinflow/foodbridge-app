import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/screens/admin/admin_dashboard_screen.dart';
import 'package:food_bridge/views/screens/auth/login_screen.dart';
import 'package:food_bridge/views/screens/user/main_layout_screen.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final duration = Duration(seconds: 2);
  final controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: duration);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          verifyToken();
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void verifyToken() {
    controller
        .isUserLoggedIn()
        .then((role) {
          if (!mounted) return;
          if (role == 'user') {
            Get.offAll(() => MainLayoutScreen());
          } else if (role == 'admin') {
            Get.offAll(() => const AdminDashboardScreen());
          } else {
            Get.offAll(() => LoginScreen());
          }
        })
        .catchError((e) {
          debugPrint('Error verifying token: $e');
          if (mounted) {
            Get.offAll(() => LoginScreen());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          Column(
            children: [
              Spacer(flex: 2),
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: .3),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: .6),
                      offset: const Offset(-6, -6),
                      blurRadius: 12,
                    ),
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: .6),
                      offset: const Offset(6, 6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Image.asset("assets/images/logo.png", fit: BoxFit.cover),
              ),

              Spacer(flex: 3),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 15,
                    width: MediaQuery.of(context).size.width / 2,
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: LinearProgressIndicator(
                      value: _animation.value,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withAlpha(
                        (17 * 2.55).toInt(),
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
