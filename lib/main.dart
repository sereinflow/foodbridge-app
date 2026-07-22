import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/theme_controller.dart';
import 'package:food_bridge/firebase_options.dart';
import 'package:food_bridge/services/di.dart';
import 'package:food_bridge/services/localization_service.dart';
import 'package:food_bridge/utils/theme/app_theme.dart';
import 'package:food_bridge/views/screens/auth/splash.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize and inject storage-backed services
  final themeController = Get.put(ThemeController());
  final localizationService = Get.put(LocalizationService());
  await themeController.init();
  await localizationService.init();

  InitialBindings().dependencies();
  runApp(const FoodBridge());
}

class FoodBridge extends StatelessWidget {
  const FoodBridge({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = Get.find<LocalizationService>();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'appName'.tr,
        locale: localizationService.currentLocale.value,
        translations: localizationService,
        fallbackLocale: LocalizationService.localeEnglish,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      );
    });
  }
}
