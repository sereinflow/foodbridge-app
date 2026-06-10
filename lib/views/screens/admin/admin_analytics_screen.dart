import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/admin_controller.dart';
import 'package:food_bridge/models/user_stats.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/widgets/loading_state_widget.dart';
import 'package:food_bridge/views/widgets/stat_card.dart';
import 'package:get/get.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  int _selectedTabIndex = 0; // 0: Overview, 1: Trends, 2: Breakdowns

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: Obx(() {
        if (controller.isAnalyticsLoading.value) {
          return const LoadingStateWidget(
            message: 'Loading analytics data...',
          );
        }

        final analytics = controller.analytics.value;
        if (analytics == null) {
          return const Center(child: Text('No analytics data available'));
        }

        Widget currentContent;
        if (_selectedTabIndex == 0) {
          currentContent = _buildStatsGrid(isWide, analytics);
        } else if (_selectedTabIndex == 1) {
          currentContent = Column(
            children: [
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildLineChart(
                      'User Growth',
                      analytics.userGrowthByMonth,
                      AppColors.primary,
                    )),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: _buildLineChart(
                      'Donations Over Time',
                      analytics.donationsByMonth,
                      AppColors.success,
                    )),
                  ],
                )
              else ...[
                _buildLineChart(
                  'User Growth',
                  analytics.userGrowthByMonth,
                  AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildLineChart(
                  'Donations Over Time',
                  analytics.donationsByMonth,
                  AppColors.success,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _buildLineChart(
                'Deliveries Over Time',
                analytics.deliveriesByMonth,
                AppColors.info,
              ),
            ],
          );
        } else {
          currentContent = Column(
            children: [
              if (isWide)
                Row(
                  children: [
                    Expanded(child: _buildPieChart(
                      'Food Categories',
                      analytics.categoryDistribution,
                    )),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: _buildPieChart(
                      'User Roles',
                      analytics.roleDistribution,
                    )),
                  ],
                )
              else ...[
                _buildPieChart(
                  'Food Categories',
                  analytics.categoryDistribution,
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildPieChart(
                  'User Roles',
                  analytics.roleDistribution,
                ),
              ],
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAnalytics,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabBar(),
                const SizedBox(height: AppSpacing.xl),
                currentContent,
                const SizedBox(height: AppSpacing.huge),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Overview', 'Trends', 'Breakdowns'];
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatsGrid(bool isWide, AdminAnalytics analytics) {
    final crossAxisCount = isWide ? 4 : 2;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.lg,
      crossAxisSpacing: AppSpacing.lg,
      childAspectRatio: 0.9,
      children: [
        StatCard(title: 'Total Users', value: analytics.totalUsers, icon: Icons.people),
        StatCard(title: 'Total Donors', value: analytics.totalDonors, icon: Icons.volunteer_activism, iconColor: AppColors.primary),
        StatCard(title: 'Volunteers', value: analytics.totalVolunteers, icon: Icons.local_shipping, iconColor: AppColors.info),
        StatCard(title: 'Buyers', value: analytics.totalBuyers, icon: Icons.shopping_bag, iconColor: AppColors.secondary),
        StatCard(title: 'NGOs', value: analytics.totalNgos, icon: Icons.account_balance, iconColor: AppColors.accent),
        StatCard(title: 'Food Listings', value: analytics.totalFoodListings, icon: Icons.fastfood),
        StatCard(title: 'Active Listings', value: analytics.totalActiveListings, icon: Icons.check_circle, iconColor: AppColors.success),
        StatCard(title: 'Completed Deliveries', value: analytics.totalCompletedDeliveries, icon: Icons.done_all, iconColor: AppColors.success),
        StatCard(title: 'Meals Donated', value: analytics.totalMealsDonated, icon: Icons.restaurant, iconColor: AppColors.primary),
        StatCard(title: 'Purchases', value: analytics.totalPurchases, icon: Icons.point_of_sale, iconColor: AppColors.secondary),
        StatCard(title: 'Total Favorites', value: analytics.totalFavoriteCounts, icon: Icons.favorite, iconColor: AppColors.error),
        StatCard(
          title: 'Resale Revenue',
          value: analytics.totalRevenue.round(),
          icon: Icons.attach_money,
          iconColor: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildLineChart(String title, Map<String, int> data, Color color) {
    if (data.isEmpty) {
      return _chartPlaceholder(title, 'No data available yet');
    }

    final sortedKeys = data.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (var i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[sortedKeys[i]]!.toDouble()));
    }

    return Container(
      height: 260,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColors.textMuted.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedKeys.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            sortedKeys[index],
                            style: AppTypography.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: AppTypography.labelSmall,
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: color,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(String title, Map<String, int> data) {
    if (data.isEmpty) {
      return _chartPlaceholder(title, 'No data available yet');
    }

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.info,
      AppColors.warning,
    ];

    final total = data.values.fold<int>(0, (a, b) => a + b);
    var colorIndex = 0;

    return Container(
      height: 280,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: data.entries.map((entry) {
                        final color = colors[colorIndex % colors.length];
                        colorIndex++;
                        final percent = total > 0 ? entry.value / total * 100 : 0;
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: '${percent.toStringAsFixed(0)}%',
                          color: color,
                          radius: 50,
                          titleStyle: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.entries.map((entry) {
                      final idx = data.keys.toList().indexOf(entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors[idx % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${entry.key} (${entry.value})',
                                style: AppTypography.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartPlaceholder(String title, String message) {
    return Container(
      height: 200,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          const Spacer(),
          Center(
            child: Text(message, style: AppTypography.bodyMedium),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
