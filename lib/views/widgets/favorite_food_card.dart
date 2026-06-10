import 'package:flutter/material.dart';
import 'package:food_bridge/models/food_post_model.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/utils/theme/spacing.dart';
import 'package:food_bridge/utils/theme/typography.dart';
import 'package:food_bridge/views/widgets/app_card.dart';
class FavoriteFoodCard extends StatelessWidget {
  final FoodPostModel post;
  final String category;
  final String expiryLabel;
  final bool isExpired;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteFoodCard({
    super.key,
    required this.post,
    required this.category,
    required this.expiryLabel,
    required this.isExpired,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                child: Image.network(
                  post.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 160,
                    color: AppColors.surfaceMuted,
                    child: const Icon(Icons.image_not_supported,
                        color: AppColors.textMuted),
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _buildBadge(
                  post.type == 'Free' ? 'Donation' : 'Resale',
                  post.type == 'Free' ? AppColors.success : AppColors.secondary,
                ),
              ),
              if (isExpired)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: _buildBadge('Expired', AppColors.error),
                ),
              Positioned(
                bottom: AppSpacing.sm,
                right: AppSpacing.sm,
                child: IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.favorite, color: AppColors.error),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTypography.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoRow(Icons.category_outlined, category),
                _buildInfoRow(Icons.scale_outlined, post.quantity),
                _buildInfoRow(Icons.person_outline, post.userName),
                _buildInfoRow(
                  Icons.schedule,
                  expiryLabel,
                  valueColor: isExpired ? AppColors.error : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _buildStatusChip(post.status),
                    const Spacer(),
                    Text(
                      'View Details',
                      style: AppTypography.labelLarge,
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(color: valueColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Available':
        color = AppColors.success;
      case 'Claimed':
      case 'Sold':
        color = AppColors.info;
      case 'Completed':
        color = AppColors.primary;
      default:
        color = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        status,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}
