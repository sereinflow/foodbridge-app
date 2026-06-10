import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/main_layout_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/screens/user/home_screen.dart';
import 'package:food_bridge/views/screens/user/my_favorites_screen.dart';
import 'package:food_bridge/views/screens/user/profile_screen.dart';
import 'package:food_bridge/views/screens/user/user_stats_screen.dart';
import 'package:get/get.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainLayoutController>();

    final List<Widget> screens = [
      const UserHomeScreen(),
      const MyFavoritesScreen(),
      const UserStatsScreen(),
      const ProfileScreen(),
    ];

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppColors.primary.withValues(alpha: 0.12),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  );
                }
                return const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(
                    color: AppColors.primary,
                    size: 24,
                  );
                }
                return const IconThemeData(
                  color: AppColors.textSecondary,
                  size: 24,
                );
              }),
            ),
            child: NavigationBar(
              backgroundColor: AppColors.card,
              selectedIndex: controller.currentIndex,
              onDestinationSelected: controller.changeIndex,
              elevation: 0,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_outline_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics_rounded),
                  label: 'Impact',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
