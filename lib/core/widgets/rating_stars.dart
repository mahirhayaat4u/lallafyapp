import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Star rating display widget
///
/// Maps to the `.stars` CSS class from the website.
class RatingStars extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final bool showCount;
  final int? reviewCount;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 16,
    this.showCount = false,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxStars, (index) {
          final starValue = index + 1;
          IconData iconData;
          if (rating >= starValue) {
            iconData = Icons.star_rounded;
          } else if (rating >= starValue - 0.5) {
            iconData = Icons.star_half_rounded;
          } else {
            iconData = Icons.star_outline_rounded;
          }
          return Icon(
            iconData,
            size: size,
            color: AppColors.gold,
          );
        }),
        if (showCount && reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: size * 0.75,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
