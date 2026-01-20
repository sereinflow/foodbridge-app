import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/controllers/home_controller.dart';
import 'package:food_bridge/controllers/user_controller.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(UserController());
    Get.put(HomeController());
  }
}
