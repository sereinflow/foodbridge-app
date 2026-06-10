import 'package:flutter/material.dart';
import 'package:food_bridge/utils/theme/colors.dart';

class StarRatingWidget extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;
  final Color activeColor;
  final Color inactiveColor;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 24,
    this.interactive = false,
    this.onRatingChanged,
    this.activeColor = AppColors.accent,
    this.inactiveColor = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starValue = index + 1;
        final isFilled = rating >= starValue;
        final isHalf = !isFilled && rating > index && rating < starValue;

        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged!(starValue)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFilled
                  ? Icons.star_rounded
                  : isHalf
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: size,
              color: isFilled || isHalf ? activeColor : inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}
