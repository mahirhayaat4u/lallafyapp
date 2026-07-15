import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../models/gifting_story.dart';
import '../../../providers/homepage_provider.dart';
import 'story_viewer.dart';

/// Static fallback stories (same as web)
const List<Map<String, String>> _staticStories = [
  {
    'id': '1',
    'name': 'Gift Jewellery',
    'btnLabel': 'GIFT JEWELLERY',
    'views': '1.9K',
    'image':
        'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600&fit=crop&q=80',
    'caption':
        '✨ Customised name jewelry and floral combos from GiftsWale ✉️',
    'link': '/shop?category=jewelry-accessories',
  },
  {
    'id': '2',
    'name': 'Gift Love',
    'btnLabel': 'GIFT LOVE',
    'views': '1.4K',
    'image':
        'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600&fit=crop&q=80',
    'caption':
        '🌃 Romantic date night surprise and gift setup ideas ft. GiftsWale ✉️❤️',
    'link': '/shop?category=flowers',
  },
  {
    'id': '3',
    'name': 'Birthday Gifts',
    'btnLabel': 'BIRTHDAY GIFTS',
    'views': '1.4K',
    'image':
        'https://images.unsplash.com/photo-1513201099705-a9746e1e201f?w=600&fit=crop&q=80',
    'caption':
        '🐱 Birthday bliss with GiftsWale custom decor & surprise cakes 🎂',
    'link': '/shop?occasion=birthday',
  },
  {
    'id': '4',
    'name': 'Anniversary Gifts',
    'btnLabel': 'ANNIVERSARY GIFTS',
    'views': '1.1K',
    'image':
        'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&fit=crop&q=80',
    'caption':
        '🏡 Celebrate milestones with cozy home anniversaries and premium settings 🥂',
    'link': '/shop?occasion=anniversary',
  },
  {
    'id': '5',
    'name': 'Send Flowers',
    'btnLabel': 'SEND FLOWERS',
    'views': '974',
    'image':
        'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?w=600&fit=crop&q=80',
    'caption':
        '💐 Fresh, hand-tied, custom florist bouquets delivered right to their door 💐',
    'link': '/shop?category=flowers',
  },
  {
    'id': '6',
    'name': 'Send Cakes',
    'btnLabel': 'SEND CAKES',
    'views': '763',
    'image':
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&fit=crop&q=80',
    'caption':
        '🍒 Rich chocolate and fresh fruit cakes baked fresh and delivered same day 🍰',
    'link': '/shop?category=cakes',
  },
];

/// Gifting Stories Section — mirrors GiftingStories.tsx
///
/// Instagram-style vertical story cards in a horizontal scroll.
/// Tapping opens a fullscreen story viewer.
class GiftingStoriesSection extends ConsumerWidget {
  const GiftingStoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(giftingStoriesProvider);

    return storiesAsync.when(
      data: (dbStories) => _buildSection(context, dbStories),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildSection(context, []),
    );
  }

  Widget _buildSection(BuildContext context, List<GiftingStory> dbStories) {
    // Use API stories or static fallback
    final stories = dbStories.isNotEmpty
        ? dbStories
        : _staticStories
            .map((s) => GiftingStory(
                  id: s['id']!,
                  name: s['name']!,
                  btnLabel: s['btnLabel']!,
                  views: s['views']!,
                  coverImageUrl: s['image']!,
                  caption: s['caption']!,
                  link: s['link']!,
                ))
            .toList();

    if (stories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
          child: Text(
            'Joyful Gifting Stories',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal story cards carousel
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.pagePadding),
            itemCount: stories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return _StoryCard(
                story: stories[index],
                onTap: () => _openStoryViewer(context, stories, index),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openStoryViewer(
      BuildContext context, List<GiftingStory> stories, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return StoryViewer(
            stories: stories,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

/// Individual story card in the horizontal carousel
class _StoryCard extends StatelessWidget {
  final GiftingStory story;
  final VoidCallback onTap;

  const _StoryCard({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CachedImage(
              imageUrl: story.coverImageUrl,
              fit: BoxFit.cover,
            ),
            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Colors.transparent,
                    Colors.transparent,
                    Color(0x99000000),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
            // Views badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility_rounded,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      story.views,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Play icon center
            if (story.videoUrl != null && story.videoUrl!.isNotEmpty)
              Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 24,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            // CTA pill button
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x4D4F46E5),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    story.btnLabel,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
