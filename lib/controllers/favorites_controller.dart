import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/data/post_repository.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:get/get.dart';

class FavoritesController extends GetxController {
  final PostRepository _repository = PostRepository();
  final AuthController _authController = Get.find<AuthController>();

  final favoritePosts = <FoodPostModel>[].obs;
  final unavailableIds = <String>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
    // Automatically fetch favorites whenever user's saved list changes
    ever(_authController.userModel, (_) => fetchFavorites());
  }

  Future<void> fetchFavorites() async {
    final user = _authController.userModel.value;
    if (user == null) {
      favoritePosts.clear();
      unavailableIds.clear();
      return;
    }

    final savedIds = user.savedPosts;
    if (savedIds.isEmpty) {
      favoritePosts.clear();
      unavailableIds.clear();
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final posts = await _repository.getFoodPostsByIds(savedIds);
      final foundIds = posts.map((p) => p.id).toSet();
      unavailableIds.value =
          savedIds.where((id) => !foundIds.contains(id)).toList();

      favoritePosts.value = posts;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load favorites: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFavorite(String postId) async {
    await _authController.toggleBookmark(postId);
    favoritePosts.removeWhere((p) => p.id == postId);
    unavailableIds.remove(postId);
  }

  bool isExpired(FoodPostModel post) {
    if (post.expiryDate == null) return false;
    return post.expiryDate!.isBefore(DateTime.now());
  }

  String getCategory(FoodPostModel post) {
    return post.tags.isNotEmpty ? post.tags.first : 'General';
  }

  String getExpiryLabel(FoodPostModel post) {
    if (post.expiryDate == null) return 'No expiry set';
    if (isExpired(post)) return 'Expired';
    final diff = post.expiryDate!.difference(DateTime.now());
    if (diff.inHours < 24) return 'Expires in ${diff.inHours}h';
    return 'Expires ${post.expiryDate!.day}/${post.expiryDate!.month}/${post.expiryDate!.year}';
  }
}
