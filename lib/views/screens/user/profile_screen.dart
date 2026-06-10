import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/auth_controller.dart';
import 'package:food_bridge/controllers/profile_controller.dart';
import 'package:food_bridge/controllers/stats_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/screens/user/reviews_screen.dart';
import 'package:food_bridge/views/screens/user/history_screen.dart';
import 'package:food_bridge/views/screens/user/my_requests_screen.dart';
import 'package:food_bridge/views/screens/user/manage_posts_screen.dart';
import 'package:food_bridge/views/screens/support/help_screen.dart';
import 'package:food_bridge/views/screens/support/info_screen.dart';
import 'package:food_bridge/views/widgets/app_card.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:food_bridge/views/widgets/custom_textfield.dart';
import 'package:food_bridge/views/widgets/star_rating_widget.dart';
import 'package:food_bridge/views/widgets/stat_card.dart';
import 'package:food_bridge/views/widgets/custom_confirmation_dialog.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    final StatsController statsController = Get.put(StatsController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isEditing.value ? Icons.close : Icons.edit_outlined,
              ),
              onPressed: controller.toggleEdit,
            ),
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.userModel.value;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
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
                    '${user.averageRating.toStringAsFixed(1)} (${user.reviewCount} reviews)',
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
                child: const Text('View Reviews'),
              ),
              const SizedBox(height: AppSpacing.xxl),

              if (!controller.isEditing.value) ...[
                _buildQuickStats(statsController),
                const SizedBox(height: AppSpacing.lg),
              ],

              if (controller.isEditing.value) ...[
                CustomTextField(
                  controller: controller.nameController,
                  icon: Icons.person,
                  hint: 'Full Name',
                  bgColor: AppColors.card,
                  shadowLight: AppColors.card,
                  shadowDark: AppColors.surfaceMuted,
                  textColor: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomTextField(
                  controller: controller.phoneController,
                  icon: Icons.phone,
                  hint: 'Phone Number',
                  bgColor: AppColors.card,
                  shadowLight: AppColors.card,
                  shadowDark: AppColors.surfaceMuted,
                  textColor: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomTextField(
                  controller: controller.bioController,
                  icon: Icons.info_outline,
                  hint: 'Bio / Address',
                  bgColor: AppColors.card,
                  shadowLight: AppColors.card,
                  shadowDark: AppColors.surfaceMuted,
                  textColor: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                CustomBWButton(
                  isLoading: controller.isLoading.value,
                  title: 'Save Changes',
                  bgColor: AppColors.primary,
                  shadowLight: AppColors.card,
                  shadowDark: AppColors.surfaceMuted,
                  textColor: Colors.white,
                  onTap: controller.updateProfile,
                ),
              ] else ...[
                _buildInfoTile(Icons.person, 'Name', user.name),
                const SizedBox(height: AppSpacing.md),
                _buildInfoTile(
                  Icons.phone,
                  'Phone',
                  (user.phone?.isNotEmpty ?? false) ? user.phone! : 'Not set',
                ),
                const SizedBox(height: AppSpacing.md),
                _buildInfoTile(
                  Icons.info,
                  'Bio',
                  (user.bio?.isNotEmpty ?? false) ? user.bio! : 'No bio',
                ),
                const SizedBox(height: AppSpacing.xxl),
                _buildSettingsSection(context, authController),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuickStats(StatsController statsController) {
    return Obx(() {
      final stats = statsController.userStats.value;
      if (statsController.isLoading.value || stats == null) {
        return const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Donations',
              value: stats.totalDonations,
              icon: Icons.volunteer_activism,
              iconColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: StatCard(
              title: 'Meals',
              value: stats.totalMealsDonated,
              icon: Icons.restaurant,
              iconColor: AppColors.success,
            ),
          ),
        ],
      );
    });
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

  Widget _buildSettingsSection(BuildContext context, AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: AppSpacing.md),
          child: Text(
            'Activity & Support',
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
                icon: Icons.shopping_bag_outlined,
                title: 'My Collections',
                subtitle: 'Track your claimed and purchased food',
                onTap: () => Get.to(() => const MyRequestsScreen()),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.event_available,
                title: 'My Posts Status',
                subtitle: 'Manage food items you have listed',
                onTap: () => Get.to(() => const ManagePostsScreen()),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.history,
                title: 'Campaign History',
                subtitle: 'View your completed donations',
                onTap: () => Get.to(() => const HistoryScreen()),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help & FAQ',
                subtitle: 'Got questions? We have answers',
                onTap: () => Get.to(() => const HelpScreen()),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About Us',
                subtitle: 'Learn more about our mission',
                onTap: () => Get.to(() => const InfoScreen(
                      title: 'About Us',
                      type: 'about',
                    )),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Terms & Service',
                subtitle: 'App rules and legal policies',
                onTap: () => Get.to(() => const InfoScreen(
                      title: 'Terms & Service',
                      type: 'terms',
                    )),
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
                title: 'Logout',
                titleColor: AppColors.secondary,
                iconColor: AppColors.secondary,
                onTap: () {
                  CustomConfirmationDialog.show(
                    title: 'Logout',
                    message: 'Are you sure you want to logout?',
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
                title: 'Delete Account',
                titleColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () {
                  CustomConfirmationDialog.show(
                    title: 'Delete Account',
                    message: 'Are you sure you want to delete your account? This action cannot be undone and you will lose all your data.',
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
              style: const TextStyle(
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
