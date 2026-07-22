import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/controllers/profile_controller.dart';
import 'package:food_bridge/controllers/stats_controller.dart';
import 'package:food_bridge/controllers/theme_controller.dart';
import 'package:food_bridge/services/localization_service.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/screens/user/reviews_screen.dart';
import 'package:food_bridge/views/screens/user/my_posts_screen.dart';
import 'package:food_bridge/views/screens/user/my_orders_screen.dart';
import 'package:food_bridge/views/widgets/app_card.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:food_bridge/views/widgets/custom_textfield.dart';
import 'package:food_bridge/views/widgets/star_rating_widget.dart';
import 'package:food_bridge/views/widgets/stat_card.dart';
import 'package:food_bridge/views/widgets/custom_confirmation_dialog.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    final StatsController statsController = Get.put(StatsController());
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final LocalizationService localizationService = Get.find<LocalizationService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: Text('tab_profile'.tr),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isEditing.value ? Icons.close : Icons.edit_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: controller.toggleEdit,
            ),
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.userModel.value;
        if (user == null) {
          return Center(child: Text('User not found'.tr));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await statsController.fetchUserStats();
            await controller.fetchRoleData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                // Premium Avatar
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.warmGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(user.name, style: AppTypography.headlineMedium),
                Text(user.email, style: AppTypography.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StarRatingWidget(
                      rating: user.averageRating,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "${user.averageRating.toStringAsFixed(1)} (${user.reviewCount} ${user.reviewCount == 1 ? 'review' : 'reviews'})",
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Get.to(() => ReviewsScreen(
                        userId: user.uid,
                        userName: user.name,
                      )),
                  child: Text('view_reviews'.tr),
                ),
                const SizedBox(height: AppSpacing.lg),

                if (!controller.isEditing.value) ...[
                  _buildRoleSpecificStats(user.role, statsController),
                  const SizedBox(height: AppSpacing.lg),
                ],

                if (controller.isEditing.value) ...[
                  CustomTextField(
                    controller: controller.nameController,
                    icon: Icons.person,
                    hint: 'fullname_hint'.tr,
                    bgColor: AppColors.card,
                    shadowLight: AppColors.card,
                    shadowDark: AppColors.surfaceMuted,
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    controller: controller.phoneController,
                    icon: Icons.phone,
                    hint: 'phone_label'.tr,
                    bgColor: AppColors.card,
                    shadowLight: AppColors.card,
                    shadowDark: AppColors.surfaceMuted,
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CustomTextField(
                    controller: controller.bioController,
                    icon: Icons.info_outline,
                    hint: 'bio_label'.tr,
                    bgColor: AppColors.card,
                    shadowLight: AppColors.card,
                    shadowDark: AppColors.surfaceMuted,
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  CustomBWButton(
                    isLoading: controller.isLoading.value,
                    title: 'save_changes'.tr,
                    bgColor: AppColors.primary,
                    shadowLight: AppColors.card,
                    shadowDark: AppColors.surfaceMuted,
                    textColor: Colors.white,
                    onTap: controller.updateProfile,
                  ),
                ] else ...[
                  // Dynamic sections based on role
                  _buildRoleSpecificDetails(user.role, controller),
                  const SizedBox(height: AppSpacing.lg),

                  _buildInfoTile(Icons.person, 'name_label'.tr, user.name),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoTile(
                    Icons.phone,
                    'phone_label'.tr,
                    (user.phone?.isNotEmpty ?? false) ? user.phone! : 'not_set'.tr,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoTile(
                    Icons.info,
                    'bio_label'.tr,
                    (user.bio?.isNotEmpty ?? false) ? user.bio! : 'no_bio'.tr,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildSettingsSection(
                    context,
                    authController,
                    themeController,
                    localizationService,
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRoleSpecificStats(String role, StatsController statsController) {
    return Obx(() {
      final stats = statsController.userStats.value;
      if (statsController.isLoading.value || stats == null) {
        return const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final r = role.toLowerCase();
      if (r == 'donor') {
        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'donations_stat'.tr,
                value: stats.totalDonations,
                icon: Icons.volunteer_activism,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'meals_stat'.tr,
                value: stats.totalMealsDonated,
                icon: Icons.restaurant,
                iconColor: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'deliveries_stat'.tr,
                value: stats.totalDeliveriesCompleted,
                icon: Icons.local_shipping,
                iconColor: AppColors.info,
              ),
            ),
          ],
        );
      } else if (r == 'volunteer') {
        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'deliveries_stat'.tr,
                value: stats.totalDeliveriesCompleted,
                icon: Icons.local_shipping,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'meals_stat'.tr,
                value: stats.totalDeliveriesCompleted * 4, // Mock total meals delivered
                icon: Icons.restaurant,
                iconColor: AppColors.success,
              ),
            ),
          ],
        );
      } else if (r == 'buyer') {
        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'purchases_stat'.tr,
                value: stats.totalPurchases,
                icon: Icons.shopping_bag,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'tab_favorites'.tr,
                value: stats.favoriteListingsCount,
                icon: Icons.favorite,
                iconColor: AppColors.secondary,
              ),
            ),
          ],
        );
      } else if (r == 'ngo') {
        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'donations_stat'.tr,
                value: stats.totalDonations,
                icon: Icons.campaign,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'meals_stat'.tr,
                value: stats.totalMealsDonated,
                icon: Icons.restaurant,
                iconColor: AppColors.success,
              ),
            ),
          ],
        );
      } else {
        // Fallback generic user
        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'donations_stat'.tr,
                value: stats.totalDonations,
                icon: Icons.volunteer_activism,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'meals_stat'.tr,
                value: stats.totalMealsDonated,
                icon: Icons.restaurant,
                iconColor: AppColors.success,
              ),
            ),
          ],
        );
      }
    });
  }

  Widget _buildRoleSpecificDetails(String role, ProfileController controller) {
    final r = role.toLowerCase();
    return Obx(() {
      if (controller.isRoleDataLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (r == 'donor' && controller.donationHistory.isNotEmpty) {
        return _buildSectionCard(
          title: 'campaign_history'.tr,
          child: Column(
            children: controller.donationHistory.take(5).map((post) {
              return ListTile(
                title: Text(post.title, style: AppTypography.titleMedium),
                subtitle: Text(
                  '${post.quantity} • ${post.pickupLocation}',
                  style: AppTypography.bodySmall,
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: post.status == 'Completed'
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    post.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: post.status == 'Completed' ? AppColors.primary : Colors.orange,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      } else if (r == 'buyer' && controller.purchaseHistory.isNotEmpty) {
        return _buildSectionCard(
          title: 'my_collections'.tr,
          child: Column(
            children: controller.purchaseHistory.take(5).map((req) {
              return ListTile(
                title: Text(req.postTitle, style: AppTypography.titleMedium),
                subtitle: Text(
                  '${req.requesterName} • ${DateFormat('yyyy-MM-dd').format(req.createdAt)}',
                  style: AppTypography.bodySmall,
                ),
                trailing: Text(
                  req.status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: req.status == 'Completed'
                        ? AppColors.primary
                        : req.status == 'Pending'
                            ? Colors.orange
                            : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      } else if (r == 'ngo' && controller.ngoCampaigns.isNotEmpty) {
        return _buildSectionCard(
          title: 'Donation Rising'.tr,
          child: Column(
            children: controller.ngoCampaigns.take(5).map((camp) {
              return ListTile(
                title: Text(camp.title, style: AppTypography.titleMedium),
                subtitle: Text('Raised: BDT ${camp.raised} / ${camp.target}'),
                trailing: CircularProgressIndicator(
                  value: camp.target > 0 ? camp.raised / camp.target : 0,
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              );
            }).toList(),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm, top: AppSpacing.md),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: child,
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodySmall),
                Text(value, style: AppTypography.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AuthController authController,
    ThemeController themeController,
    LocalizationService localizationService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.md),
          child: Text(
            'activity_support'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.article_outlined,
                title: "My Posts",
                subtitle: "Manage your food listings",
                onTap: () => Get.to(() => const MyPostsScreen()),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.shopping_bag_outlined,
                title: "My Orders",
                subtitle: "Track resale food orders",
                onTap: () => Get.to(() => const MyOrdersScreen()),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.restore_outlined,
                title: 'reset_onboarding'.tr,
                subtitle: 'reset_onboarding_desc'.tr,
                onTap: () {
                  CustomConfirmationDialog.show(
                    title: 'reset_onboarding'.tr,
                    message: 'Are you sure you want to reset onboarding? You will see the introduction screens on next launch.',
                    onConfirm: () async {
                      Get.back();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_completed', false);
                      Get.snackbar('success'.tr, 'Onboarding has been reset');
                    },
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'help_faq'.tr,
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'about_us'.tr,
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'terms'.tr,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.logout_rounded,
                title: 'logout'.tr,
                titleColor: AppColors.secondary,
                iconColor: AppColors.secondary,
                onTap: () {
                  CustomConfirmationDialog.show(
                    title: 'logout'.tr,
                    message: 'logout_confirm'.tr,
                    onConfirm: () {
                      Get.back();
                      authController.logout();
                    },
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'delete_account'.tr,
                titleColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () {
                  CustomConfirmationDialog.show(
                    title: 'delete_account'.tr,
                    message: 'delete_confirm'.tr,
                    onConfirm: () {
                      Get.back();
                      authController.deleteAccount();
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted.withValues(alpha: 0.8),
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

}
