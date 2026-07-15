import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../models/category.dart';

/// Category emoji fallbacks (mirrors CAT_EMOJIS from HomePage.tsx)
const _catEmojis = <String, String>{
  'flowers': '💐',
  'chocolates': '🍫',
  'jewelry': '💎',
  'perfumes': '🌸',
  'soft toys': '🧸',
  'electronics': '📱',
  'home decor': '🏡',
  'books': '📚',
  'clothing': '👗',
  'skincare': '✨',
  'cakes': '🍰',
  'plants': '🪴',
  'experiences': '🎸',
  'personalised': '☕',
};

/// Category circles section — mirrors the circle-categories-section
class CategoryCircles extends StatelessWidget {
  final List<Category> categories;
  final Function(String slug)? onCategoryTap;

  const CategoryCircles({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final emoji = _catEmojis[cat.name.toLowerCase()] ?? '🎁';
          final bool isActive = index == 0; // Highlight the first category matching the mockup

          return GestureDetector(
            onTap: () => onCategoryTap?.call(cat.slug),
            child: SizedBox(
              width: 82,
              child: Column(
                children: [
                  // Squircle Image Container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: cat.imageUrl != null
                        ? CachedImage(
                            imageUrl: cat.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  // Label (Not Bold, regular font, pink for active, dark grey for inactive)
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.w400, // Not bold
                      color: isActive ? const Color(0xFFEF476F) : const Color(0xFF334155),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
