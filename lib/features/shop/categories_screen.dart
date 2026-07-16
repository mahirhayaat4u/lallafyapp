import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cached_image.dart';
import '../../models/age_group.dart';
import '../../models/category.dart';
import '../../providers/cart_provider.dart';
import '../../providers/homepage_provider.dart';

/// Categories Screen — matching exact "Shop by Category" design from screenshot
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  static final Map<String, Map<String, dynamic>> _ageConfig = {
    '0–1 Years': {
      'subtitle': 'Toys for Newborns',
      'bgColor': const Color(0xFFE8F5E9),
      'textColor': const Color(0xFF1B5E20),
      'image': 'https://res.cloudinary.com/dbm4tkheh/image/upload/v1772280674/retail-website/categories/0-1.png',
    },
    '0-1 Years': {
      'subtitle': 'Toys for Newborns',
      'bgColor': const Color(0xFFE8F5E9),
      'textColor': const Color(0xFF1B5E20),
      'image': 'https://res.cloudinary.com/dbm4tkheh/image/upload/v1772280674/retail-website/categories/0-1.png',
    },
    '1–3 Years': {
      'subtitle': 'Early Learning Toys',
      'bgColor': const Color(0xFFFCE4EC),
      'textColor': const Color(0xFFC2185B),
      'image': 'https://res.cloudinary.com/dbm4tkheh/image/upload/v1772280674/retail-website/categories/1-3.png',
    },
    '1-3 Years': {
      'subtitle': 'Early Learning Toys',
      'bgColor': const Color(0xFFFCE4EC),
      'textColor': const Color(0xFFC2185B),
      'image': 'https://res.cloudinary.com/dbm4tkheh/image/upload/v1772280674/retail-website/categories/1-3.png',
    },
    '4–12 Years': {
      'subtitle': 'Fun & Educational',
      'bgColor': const Color(0xFFE1F5FE),
      'textColor': const Color(0xFF0D47A1),
      'image': 'https://res.cloudinary.com/dbm4tkheh/image/upload/v1772280674/retail-website/categories/4-12.png',
    },
    '4-12 Years': {
      'subtitle': 'Fun & Educational',
      'bgColor': const Color(0xFFE1F5FE),
      'textColor': const Color(0xFF0D47A1),
      'image': 'https://res.cloudinary.com/dbm4tkheh/image/upload/v1772280674/retail-website/categories/4-12.png',
    },
    '13+ Years': {
      'subtitle': 'Gifts for Everyone',
      'bgColor': const Color(0xFFF3E5F5),
      'textColor': const Color(0xFF4A148C),
      'image': 'https://res.cloudinary.com/dbm4tkheh/image/upload/v1772280674/retail-website/categories/13plus.png',
    },
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ageGroupsAsync = ref.watch(ageGroupsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF1A1C23), size: 28),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Shop by Category',
          style: AppTextStyles.h2.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1C23),
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1A1C23), size: 24),
                onPressed: () => context.push('/cart'),
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF448C),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cart.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. 2x2 Grid of Age Group Cards ──
            ageGroupsAsync.when(
              data: (ageGroups) => _buildAgeGroupGrid(context, ageGroups),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: Color(0xFFFF448C)),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // ── 2. Promo Offer Banner Card ──
            _buildPromoBanner(context),

            const SizedBox(height: 24),

            // ── 3. Product Categories Grid ──
            Text(
              'All Toy Categories',
              style: AppTextStyles.h2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1C23),
              ),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) => _buildCategoryGrid(context, categories),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeGroupGrid(BuildContext context, List<AgeGroup> ageGroups) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ageGroups.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final group = ageGroups[index];
        final config = _ageConfig[group.label] ?? {
          'subtitle': 'Toys & Games',
          'bgColor': const Color(0xFFF3F4F6),
          'textColor': const Color(0xFF1F2937),
          'image': group.image,
        };

        final Color bgColor = config['bgColor'] as Color;
        final Color textColor = config['textColor'] as Color;
        final String subtitle = config['subtitle'] as String;
        final String? imageUrl = group.image ?? (config['image'] as String?);

        return GestureDetector(
          onTap: () => context.push('/shop?ageGroup=${Uri.encodeComponent(group.label)}'),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Upper Image Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? CachedImage(imageUrl: imageUrl, fit: BoxFit.contain)
                        : Center(
                            child: Text(
                              group.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                  ),
                ),

                // Lower Info + Chevron Button Area
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 10, bottom: 12, top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              group.label,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textColor.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F5), Color(0xFFF3E5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFCE4EC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1C23),
                    ),
                    children: [
                      TextSpan(text: 'Flat '),
                      TextSpan(
                        text: '10% OFF',
                        style: TextStyle(color: Color(0xFFFF448C), fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'on First Order',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF448C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Use Code: LALLAFY10',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text('🎁✨', style: TextStyle(fontSize: 48)),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<Category> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        return GestureDetector(
          onTap: () => context.push('/shop?category=${cat.slug}'),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CachedImage(
                    imageUrl: cat.imageUrl ?? '',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat.name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1C23),
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
    );
  }
}
