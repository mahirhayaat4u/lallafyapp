import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/occasion_tab.dart';
import '../../../providers/homepage_provider.dart';
import 'product_card.dart';

/// Occasion Tabs Section — mirrors OccasionSpecialSection.tsx
///
/// Shows a tabbed horizontal product carousel filtered by occasion.
/// "Tailored For Your Occasions" — Birthday, Anniversary, Wedding, etc.

/// Static fallback tabs (same as web)
const List<Map<String, dynamic>> _staticTabs = [
  {'name': 'Birthday', 'icon': Icons.cake_rounded},
  {'name': 'Anniversary', 'icon': Icons.calendar_today_rounded},
  {'name': 'Love N Romance', 'icon': Icons.favorite_rounded},
  {'name': 'Wedding', 'icon': Icons.diamond_rounded},
  {'name': 'Congratulations', 'icon': Icons.emoji_events_rounded},
  {'name': 'Thank You', 'icon': Icons.thumb_up_alt_rounded},
];

/// Map icon name strings from API to Flutter icons
const Map<String, IconData> _iconMap = {
  'cake': Icons.cake_rounded,
  'heart': Icons.favorite_rounded,
  'ring': Icons.diamond_rounded,
  'gift': Icons.card_giftcard_rounded,
  'briefcase': Icons.work_rounded,
  'star': Icons.star_rounded,
};

class OccasionTabsSection extends ConsumerStatefulWidget {
  const OccasionTabsSection({super.key});

  @override
  ConsumerState<OccasionTabsSection> createState() =>
      _OccasionTabsSectionState();
}

class _OccasionTabsSectionState extends ConsumerState<OccasionTabsSection> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabsAsync = ref.watch(occasionTabsProvider);

    return tabsAsync.when(
      data: (dbTabs) => _buildSection(context, dbTabs),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildSection(context, []), // Use static fallback
    );
  }

  Widget _buildSection(BuildContext context, List<OccasionTab> dbTabs) {
    // Use dynamic tabs from API, or static fallback
    final bool useDynamic = dbTabs.isNotEmpty;

    final tabNames = useDynamic
        ? dbTabs.map((t) => t.name).toList()
        : _staticTabs.map((t) => t['name'] as String).toList();

    final tabIcons = useDynamic
        ? dbTabs
            .map((t) => _iconMap[t.icon] ?? Icons.card_giftcard_rounded)
            .toList()
        : _staticTabs.map((t) => t['icon'] as IconData).toList();

    if (_activeTabIndex >= tabNames.length) {
      _activeTabIndex = 0;
    }

    // Get active tab for product fetching
    final OccasionTab activeTab;
    if (useDynamic) {
      activeTab = dbTabs[_activeTabIndex];
    } else {
      activeTab = OccasionTab(
        id: tabNames[_activeTabIndex],
        name: tabNames[_activeTabIndex],
      );
    }

    return Container(
      color: const Color(0xFFFAFAF8),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.pagePadding),
            child: Text(
              'Tailored For Your Occasions',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tab bar
          _buildTabBar(tabNames, tabIcons),
          const SizedBox(height: 20),

          // Products carousel for active tab
          _OccasionProductsCarousel(tab: activeTab),
        ],
      ),
    );
  }

  Widget _buildTabBar(List<String> tabNames, List<IconData> tabIcons) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.pagePadding),
        itemCount: tabNames.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = index == _activeTabIndex;
          return GestureDetector(
            onTap: () => setState(() => _activeTabIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x04000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabIcons[index],
                      size: 16,
                      color: isActive ? Colors.white : AppColors.textSubtle,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tabNames[index],
                      style: AppTextStyles.bodySm.copyWith(
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Product carousel for the active occasion tab
class _OccasionProductsCarousel extends ConsumerWidget {
  final OccasionTab tab;
  const _OccasionProductsCarousel({required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(occasionProductsProvider(tab));

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                'No products found for this occasion.',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          );
        }
        return SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.pagePadding),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) => ProductCard(
              product: products[index],
              onTap: () {
                context.push('/product/${products[index].id}');
              },
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
