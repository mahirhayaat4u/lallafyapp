import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../models/product.dart';
import '../../../models/section_banner.dart';
import '../../../providers/homepage_provider.dart';

/// My First Year Section — mirrors Myfirstyear.jsx from lallafy.com
/// Controlled dynamically by Admin via SectionBanners (section === "myfirstyear") and DB products (ageGroup === "0–1 Years").
class MyFirstYearSection extends ConsumerWidget {
  const MyFirstYearSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(sectionBannersProvider);
    final productsAsync = ref.watch(myFirstYearProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF448C),
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.h2.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1A1C23),
                                letterSpacing: -0.5,
                              ),
                              children: const [
                                TextSpan(text: 'My First '),
                                TextSpan(
                                  text: 'Toy',
                                  style: TextStyle(color: Color(0xFFFF448C)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Safe, soft & loving toys for your little one's first year.",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/shop?ageGroup=0–1 Years'),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2, left: 8),
                  child: Row(
                    children: const [
                      Text(
                        'Explore All',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF448C),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFFF448C),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Main Hero Card + Product Cards ──
        bannersAsync.when(
          data: (banners) {
            final myFirstYearBanner = banners.cast<SectionBanner?>().firstWhere(
                  (b) => b?.section == 'myfirstyear',
                  orElse: () => null,
                );

            return productsAsync.when(
              data: (products) => _buildGrid(context, myFirstYearBanner, products),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildGrid(
    BuildContext context,
    SectionBanner? banner,
    List<Product> products,
  ) {
    if (products.isEmpty && banner == null) {
      return const SizedBox.shrink();
    }

    final featuredProduct = products.isNotEmpty ? products.first : null;
    final bannerImg = banner?.image ?? featuredProduct?.primaryImage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 1. Featured Large Hero Card (Admin SectionBanner or Top Product)
          if (bannerImg != null && bannerImg.isNotEmpty)
            GestureDetector(
              onTap: () {
                if (banner?.categoryId != null) {
                  context.push('/shop?category=${banner!.categoryId}');
                } else if (featuredProduct != null) {
                  context.push('/product/${featuredProduct.id}');
                } else {
                  context.push('/shop?ageGroup=0–1 Years');
                }
              },
              child: Container(
                height: 185,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedImage(
                      imageUrl: bannerImg,
                      fit: BoxFit.cover,
                    ),

                    // Gradient Overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0x30000000),
                            Color(0xDD000000),
                          ],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('🍼 ', style: TextStyle(fontSize: 10)),
                                Text(
                                  '0–1 YEARS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            banner?.title ?? featuredProduct?.name ?? 'My First Toy Collection',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (featuredProduct != null && banner == null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '₹${featuredProduct.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 14),

          // 2. Horizontal Scroll of Product Cards
          Builder(builder: (context) {
            final productList = banner != null ? products : products.skip(1).toList();
            if (productList.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: productList.take(6).length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final prod = productList[index];
                  return _buildSmallProductCard(context, prod);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSmallProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        width: 120,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedImage(
              imageUrl: product.primaryImage,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xB0000000),
                  ],
                  stops: [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF80D8FF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
