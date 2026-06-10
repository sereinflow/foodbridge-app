import 'package:flutter/material.dart';
import 'package:food_bridge/utils/theme/colors.dart';

class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? activeColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.activeColor,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool hasAction = widget.onTap != null;

    return GestureDetector(
      onTapDown: (_) {
        if (hasAction) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (hasAction) {
          setState(() => _isPressed = false);
        }
      },
      onTapCancel: () {
        if (hasAction) {
          setState(() => _isPressed = false);
        }
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isPressed
                ? (widget.activeColor ?? AppColors.primary.withValues(alpha: 0.08))
                : (widget.color ?? Colors.white),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _isPressed
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.grey.shade100,
              width: 1,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
