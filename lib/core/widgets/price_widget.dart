import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Price display widget with original/discounted price formatting
///
/// Maps to the `.price`, `.price-original`, `.price-discounted` CSS classes.
class PriceWidget extends StatelessWidget {
  final double price;
  final double? discountPrice;
  final bool isLarge;

  const PriceWidget({
    super.key,
    required this.price,
    this.discountPrice,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = discountPrice != null && discountPrice! < price;
    final displayPrice = hasDiscount ? discountPrice! : price;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          '${AppConstants.currencySymbol}${displayPrice.toStringAsFixed(0)}',
          style: (isLarge
                  ? AppTextStyles.h2
                  : AppTextStyles.price)
              .copyWith(
            color: hasDiscount ? AppColors.primary : AppColors.text,
          ),
        ),
        if (hasDiscount)
          Text(
            '${AppConstants.currencySymbol}${price.toStringAsFixed(0)}',
            style: isLarge
                ? AppTextStyles.body.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSubtle,
                  )
                : AppTextStyles.priceOriginal,
          ),
        if (hasDiscount)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${((price - discountPrice!) / price * 100).round()}% OFF',
              style: AppTextStyles.bodyXs.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
