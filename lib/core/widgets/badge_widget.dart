import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Status badge widget
///
/// Maps to the `.badge-*` CSS classes from the website.
enum BadgeVariant { primary, success, warning, danger, info, muted }

class BadgeWidget extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;

  const BadgeWidget({
    super.key,
    required this.label,
    this.variant = BadgeVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = _getColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getColors() {
    return switch (variant) {
      BadgeVariant.primary => (AppColors.primaryGlow, AppColors.primaryLight),
      BadgeVariant.success => (
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success,
        ),
      BadgeVariant.warning => (
          AppColors.warning.withValues(alpha: 0.12),
          AppColors.warning,
        ),
      BadgeVariant.danger => (
          AppColors.danger.withValues(alpha: 0.12),
          AppColors.danger,
        ),
      BadgeVariant.info => (
          AppColors.info.withValues(alpha: 0.12),
          AppColors.info,
        ),
      BadgeVariant.muted => (AppColors.bgElevated, AppColors.textMuted),
    };
  }
}
