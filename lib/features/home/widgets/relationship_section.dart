import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../providers/homepage_provider.dart';

/// Every Relationship Section — mirrors EveryRelationshipSection.tsx
///
/// Avatar-style portrait cards in a horizontal scroll.
/// Uses API data if available, otherwise shows static fallback.

const List<Map<String, String>> _staticRelationships = [
  {
    'name': 'Him',
    'link': '/shop?relation=husband',
    'image':
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&auto=format&fit=crop&q=80',
  },
  {
    'name': 'Her',
    'link': '/shop?relation=wife',
    'image':
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300&auto=format&fit=crop&q=80',
  },
  {
    'name': 'Kids',
    'link': '/shop?relation=son',
    'image':
        'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=300&auto=format&fit=crop&q=80',
  },
  {
    'name': 'Friend',
    'link': '/shop?relation=friend',
    'image':
        'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=300&auto=format&fit=crop&q=80',
  },
  {
    'name': 'Girlfriend',
    'link': '/shop?relation=girlfriend',
    'image':
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80',
  },
  {
    'name': 'Boyfriend',
    'link': '/shop?relation=boyfriend',
    'image':
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&auto=format&fit=crop&q=80',
  },
  {
    'name': 'Wife',
    'link': '/shop?relation=wife',
    'image':
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&auto=format&fit=crop&q=80',
  },
  {
    'name': 'Husband',
    'link': '/shop?relation=husband',
    'image':
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop&q=80',
  },
];

class RelationshipSection extends ConsumerWidget {
  const RelationshipSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(relationshipCardsProvider);

    return cardsAsync.when(
      data: (dbCards) {
        // Use API data if available, otherwise static fallback
        final items = dbCards.isNotEmpty
            ? dbCards
                .map((c) => {
                      'name': c.title,
                      'link': c.link ?? '/shop',
                      'image': c.imageUrl,
                    })
                .toList()
            : _staticRelationships;

        return _buildSection(context, items);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildSection(context, _staticRelationships),
    );
  }

  Widget _buildSection(BuildContext context, List<Map<String, String>> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
          child: Text(
            'For Every Relationship',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Horizontal avatar cards
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.pagePadding),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return _RelationshipCard(
                name: item['name']!,
                imageUrl: item['image']!,
                onTap: () {
                  final link = item['link'] ?? '/shop';
                  String route = link;
                  if (route.startsWith('/shop')) {
                    final uri = Uri.parse(route);
                    final queryParams = Map<String, String>.from(uri.queryParameters);
                    queryParams['title'] = item['name']!;
                    route = Uri(path: uri.path, queryParameters: queryParams).toString();
                  }
                  context.push(route);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RelationshipCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  const _RelationshipCard({
    required this.name,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            // Square avatar card with rounded corners
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.04),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedImage(
                imageUrl: imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                borderRadius: 24,
              ),
            ),
            const SizedBox(height: 12),
            // Name label
            Text(
              name,
              style: AppTextStyles.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
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
