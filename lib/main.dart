import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/firebase_options.dart';
import 'package:food_bridge/services/di.dart';
import 'package:food_bridge/views/screens/auth/splash.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  InitialBindings().dependencies();
  runApp(FoodBridge());
}

class FoodBridge extends StatelessWidget {
  const FoodBridge({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Bridge',
      home: SplashScreen(),
    );
  }
}
