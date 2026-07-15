import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Primary call-to-action button with gradient background
///
/// 💡 React Native equivalent: A styled TouchableOpacity / Pressable
/// In Flutter, we create a custom widget that wraps ElevatedButton.
///
/// Maps to the `.btn-primary` CSS class from the website.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isSmall;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSmall = false,
    this.isFullWidth = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? Colors.white;

    final child = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: isSmall ? 14 : 18,
            height: isSmall ? 14 : 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? AppColors.primary : effectiveTextColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: isSmall ? 16 : 20),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTextStyles.buttonText.copyWith(
            color: isOutlined ? AppColors.primary : effectiveTextColor,
            fontSize: isSmall ? 12 : 14,
          ),
        ),
      ],
    );

    final padding = EdgeInsets.symmetric(
      horizontal: isSmall ? 16 : 24,
      vertical: isSmall ? 10 : 14,
    );

    if (isOutlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: padding,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                isSmall ? AppTheme.radiusSm : AppTheme.radiusMd,
              ),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: backgroundColor == null ? AppColors.gradientPrimary : null,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            isSmall ? AppTheme.radiusSm : AppTheme.radiusMd,
          ),
          boxShadow: AppColors.shadowPrimary,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                isSmall ? AppTheme.radiusSm : AppTheme.radiusMd,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
