import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../models/homepage_card.dart';

/// Generic homepage section with title + horizontal scrolling cards
///
/// Used for: Flowers, Relationships, Luxury, Personalize, Combos sections
/// 💡 Mirrors each homepage section component from homepage_components/
class HomepageSection extends StatelessWidget {
  final String label;
  final String title;
  final String? subtitle;
  final List<HomepageCard> cards;
  final Function(String link, String title)? onCardTap;
  final double cardWidth;
  final double cardHeight;
  final bool showLabels;

  const HomepageSection({
    super.key,
    required this.label,
    required this.title,
    this.subtitle,
    required this.cards,
    this.onCardTap,
    this.cardWidth = 150,
    this.cardHeight = 200,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.sectionLabel,
              ),
              const SizedBox(height: 4),
              Text(title, style: AppTextStyles.h2),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal card list
        SizedBox(
          height: cardHeight + (showLabels ? 44 : 0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.pagePadding),
            itemCount: cards.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final card = cards[index];
              return _buildCard(card);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(HomepageCard card) {
    return GestureDetector(
      onTap: () {
        if (card.link != null && onCardTap != null) {
          onCardTap!(card.link!, card.title);
        }
      },
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card image
            Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppColors.shadowSm,
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedImage(
                imageUrl: card.imageUrl,
                width: cardWidth,
                height: cardHeight,
                fit: BoxFit.cover,
                borderRadius: AppTheme.radiusLg,
              ),
            ),
            if (showLabels) ...[
              const SizedBox(height: 10),
              Text(
                card.title,
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (card.subtitle != null)
                Text(
                  card.subtitle!,
                  style: AppTextStyles.bodyXs
                      .copyWith(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
