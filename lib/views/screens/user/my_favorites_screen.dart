import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/favorites_controller.dart';
import 'package:food_bridge/controllers/main_layout_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/screens/user/food_post_details_screen.dart';
import 'package:food_bridge/views/widgets/empty_state_widget.dart';
import 'package:food_bridge/views/widgets/favorite_food_card.dart';
import 'package:food_bridge/views/widgets/loading_state_widget.dart';
import 'package:get/get.dart';

class MyFavoritesScreen extends StatelessWidget {
  const MyFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoritesController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingStateWidget(message: 'Loading your favorites...');
        }

        if (controller.hasError.value) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Try Again',
            onAction: controller.fetchFavorites,
          );
        }

        final hasUnavailable = controller.unavailableIds.isNotEmpty;
        final isEmpty =
            controller.favoritePosts.isEmpty && !hasUnavailable;

        if (isEmpty) {
          return EmptyStateWidget(
            icon: Icons.favorite_border,
            title: 'No favorites yet',
            subtitle:
                'Tap the heart icon on food listings to save them here.',
            actionLabel: 'Explore Food',
            onAction: () => Get.find<MainLayoutController>().changeIndex(0),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchFavorites,
          color: AppColors.primary,
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              if (hasUnavailable)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          '${controller.unavailableIds.length} saved listing(s) are no longer available (deleted or removed).',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ...controller.favoritePosts.map((post) {
                final expired = controller.isExpired(post);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: FavoriteFoodCard(
                    post: post,
                    category: controller.getCategory(post),
                    expiryLabel: controller.getExpiryLabel(post),
                    isExpired: expired,
                    onTap: () => Get.to(
                      () => FoodPostDetailsScreen(post: post),
                    ),
                    onRemove: () => controller.removeFavorite(post.id),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
