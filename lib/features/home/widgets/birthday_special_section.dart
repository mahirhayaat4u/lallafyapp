import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';

/// Birthday Special Section — mirrors BirthdaySpecialSection.tsx
///
/// Layout: Left banner card + horizontally scrollable category items
class BirthdaySpecialSection extends StatelessWidget {
  const BirthdaySpecialSection({super.key});

  static const List<Map<String, String>> _birthdayItems = [
    {
      'name': 'Flowers',
      'slug': 'flowers',
      'image':
          'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?w=350&fit=crop&q=80',
    },
    {
      'name': 'Cakes',
      'slug': 'cakes',
      'image':
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=350&fit=crop&q=80',
    },
    {
      'name': 'Personalised',
      'slug': 'personalised',
      'image':
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=350&fit=crop&q=80',
    },
    {
      'name': 'Plants',
      'slug': 'plants',
      'image':
          'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=350&fit=crop&q=80',
    },
    {
      'name': 'Gift Sets',
      'slug': 'gift-sets',
      'image':
          'https://images.unsplash.com/photo-1549417229-aa67d3263c09?w=350&fit=crop&q=80',
    },
    {
      'name': 'Hampers',
      'slug': 'gift-hampers',
      'image':
          'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?w=350&fit=crop&q=80',
    },
    {
      'name': 'Balloon Decor',
      'slug': 'balloon-decor',
      'image':
          'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=350&fit=crop&q=80',
    },
    {
      'name': 'Bestsellers',
      'slug': 'all',
      'image':
          'https://images.unsplash.com/photo-1548907040-4d42b52125bf?w=350&fit=crop&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left Banner Card ──
          _buildBannerCard(context),
          const SizedBox(height: 20),
          // ── Category Items Grid (horizontal scroll) ──
          _buildCategoryCarousel(context),
        ],
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/shop?occasion=birthday'),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppColors.shadowMd,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            const CachedImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1513201099705-a9746e1e201f?w=600&auto=format&fit=crop&q=80',
              fit: BoxFit.cover,
            ),
            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x73000000),
                    Color(0xF2C2185B),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 20,
              left: 20,
              right: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Birthdays Made Special',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Joyful surprises and curated boxes to make their special day unforgettable.',
                    style: AppTextStyles.bodyXs.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow button
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFD83545),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40D83545),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCarousel(BuildContext context) {
    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _birthdayItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = _birthdayItems[index];
          return _buildCategoryItem(context, item);
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        if (item['slug'] == 'all') {
          context.push('/shop?sort=popular');
        } else {
          context.push('/shop?category=${item['slug']}');
        }
      },
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            // Borderless Squircle Image Container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedImage(
                imageUrl: item['image'],
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            // Label (Not Bold, regular font)
            Text(
              item['name']!,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF334155),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
