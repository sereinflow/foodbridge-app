import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/stats_controller.dart';
import 'package:food_bridge/models/user_stats.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/widgets/empty_state_widget.dart';
import 'package:food_bridge/views/widgets/loading_state_widget.dart';
import 'package:food_bridge/views/widgets/stat_card.dart';
import 'package:get/get.dart';

class UserStatsScreen extends StatelessWidget {
  const UserStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StatsController());
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Impact')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingStateWidget(message: 'Calculating your impact...');
        }

        if (controller.hasError.value || controller.userStats.value == null) {
          return EmptyStateWidget(
            icon: Icons.analytics_outlined,
            title: 'Unable to load statistics',
            actionLabel: 'Retry',
            onAction: controller.fetchUserStats,
          );
        }

        final stats = controller.userStats.value!;

        return RefreshIndicator(
          onRefresh: controller.fetchUserStats,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your FoodBridge Impact',
                        style: AppTypography.headlineLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Every action helps reduce food waste and support communities.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _buildMilestoneCard(stats),
                const SizedBox(height: AppSpacing.xxl),
                Text('Statistics', style: AppTypography.headlineMedium),
                const SizedBox(height: AppSpacing.lg),
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 0.95,
                  children: [
                    StatCard(
                      title: 'Total Donations',
                      value: stats.totalDonations,
                      icon: Icons.volunteer_activism,
                      iconColor: AppColors.primary,
                    ),
                    StatCard(
                      title: 'Meals Donated',
                      value: stats.totalMealsDonated,
                      icon: Icons.restaurant,
                      iconColor: AppColors.success,
                    ),
                    StatCard(
                      title: 'Deliveries Completed',
                      value: stats.totalDeliveriesCompleted,
                      icon: Icons.local_shipping_outlined,
                      iconColor: AppColors.info,
                    ),
                    StatCard(
                      title: 'Total Purchases',
                      value: stats.totalPurchases,
                      icon: Icons.shopping_cart_outlined,
                      iconColor: AppColors.secondary,
                    ),
                    StatCard(
                      title: 'Listings Created',
                      value: stats.totalFoodListingsCreated,
                      icon: Icons.post_add,
                      iconColor: AppColors.accent,
                    ),
                    StatCard(
                      title: 'Favorite Listings',
                      value: stats.favoriteListingsCount,
                      icon: Icons.favorite,
                      iconColor: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                _buildVisualImpactChart(stats),
                const SizedBox(height: AppSpacing.huge),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMilestoneCard(UserStats stats) {
    // Calculate total impact score (experience points)
    final score = (stats.totalDonations * 10) +
        (stats.totalMealsDonated * 2) +
        (stats.totalDeliveriesCompleted * 15) +
        stats.totalPurchases +
        (stats.totalFoodListingsCreated * 5);

    final nextGoal = score < 100 ? 100 : (score < 500 ? 500 : 1000);
    final progress = score / nextGoal;

    String rankName;
    IconData badgeIcon;
    Color badgeColor;

    if (score < 100) {
      rankName = 'Eco Rookie';
      badgeIcon = Icons.eco_outlined;
      badgeColor = Colors.lightGreen;
    } else if (score < 500) {
      rankName = 'Food Saver';
      badgeIcon = Icons.volunteer_activism;
      badgeColor = AppColors.primary;
    } else {
      rankName = 'Bridge Champion';
      badgeIcon = Icons.workspace_premium_rounded;
      badgeColor = AppColors.accent;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(badgeIcon, color: badgeColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rankName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                    Text(
                      '$score / $nextGoal XP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress > 1.0 ? 1.0 : progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'List foods and complete collections to gain XP!',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualImpactChart(UserStats stats) {
    final Map<String, double> chartData = {
      'Donations': stats.totalDonations.toDouble(),
      'Meals': stats.totalMealsDonated.toDouble(),
      'Deliveries': stats.totalDeliveriesCompleted.toDouble(),
      'Purchases': stats.totalPurchases.toDouble(),
      'Listings': stats.totalFoodListingsCreated.toDouble(),
    };

    final double maxVal = chartData.values.fold(5.0, (prev, val) => val > prev ? val : prev);

    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impact Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.25,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= chartData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            chartData.keys.elementAt(index),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(chartData.length, (index) {
                  final key = chartData.keys.elementAt(index);
                  final val = chartData.values.elementAt(index);
                  Color barColor;
                  switch (key) {
                    case 'Donations':
                      barColor = AppColors.primary;
                      break;
                    case 'Meals':
                      barColor = AppColors.success;
                      break;
                    case 'Deliveries':
                      barColor = AppColors.info;
                      break;
                    case 'Purchases':
                      barColor = AppColors.secondary;
                      break;
                    default:
                      barColor = AppColors.accent;
                  }
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: val,
                        color: barColor,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal * 1.25,
                          color: Colors.grey.shade50,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
