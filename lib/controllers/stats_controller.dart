import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/data/stats_repository.dart';
import 'package:food_bridge/models/user_stats.dart';
import 'package:get/get.dart';

class StatsController extends GetxController {
  final StatsRepository _repository = StatsRepository();
  final AuthController _authController = Get.find<AuthController>();

  final userStats = Rxn<UserStats>();
  final isLoading = false.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserStats();
  }

  Future<void> fetchUserStats() async {
    final user = _authController.userModel.value;
    if (user == null) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      userStats.value = await _repository.getUserStats(
        user.uid,
        user.savedPosts,
      );
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
