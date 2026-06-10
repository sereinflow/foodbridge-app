import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/controllers/home_controller.dart';
import 'package:food_bridge/controllers/user_controller.dart';
import 'package:food_bridge/controllers/main_layout_controller.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    // Lazy load controllers to avoid heavy operations during startup
    Get.lazyPut(() => UserController(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.put(MainLayoutController());
  }
}
