import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final currentThemeMode = ThemeMode.light.obs;

  Future<void> init() async {
    Get.changeThemeMode(ThemeMode.light);
  }

  void setThemeMode(ThemeMode mode) {
    // Lock to Light mode
    Get.changeThemeMode(ThemeMode.light);
  }

  bool get isDarkMode => false;
}
