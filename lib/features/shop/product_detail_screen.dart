import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cached_image.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/badge_widget.dart';
import '../../core/widgets/app_button.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';

/// Product detail provider — fetches by slug
final productDetailProvider =
    FutureProvider.family<Product, String>((ref, slug) async {
  final response = await DioClient().get(ApiConstants.productBySlug(slug));
  final data = response.data['data'];
  return Product.fromJson(data['product'] ?? data);
});

/// Product Detail Screen — mirrors ProductDetailPage.tsx
///
/// Layout: Image gallery → Product info → Price → Stock → Description →
/// Quantity → Add to Cart / Wishlist → Store card → Reviews
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProductDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _activeImageIndex = 0;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.slug));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: productAsync.when(
        data: (product) => _buildProductDetail(product),
        loading: () => const LoadingWidget(message: 'Loading product...'),
        error: (err, _) => _buildError(err.toString()),
      ),
    );
  }

  Widget _buildError(String message) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Product not found', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(message,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          AppButton(
            label: 'Back to Shop',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail(Product product) {
    return CustomScrollView(
      slivers: [
        // ── Collapsing App Bar with image ──
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.width * 0.85,
          pinned: true,
          leading: _circleButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => context.pop(),
          ),
          actions: [
            _circleButton(
              icon: Icons.favorite_border_rounded,
              onTap: () {
                // TODO: Phase 5 — wishlist toggle
              },
            ),
            const SizedBox(width: 8),
            _circleButton(
              icon: Icons.share_outlined,
              onTap: () {
                // TODO: share product
              },
            ),
            const SizedBox(width: 12),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageGallery(product),
          ),
        ),

        // ── Product Info ──
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  if (product.categoryName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: BadgeWidget(
                        label: product.categoryName!,
                        variant: BadgeVariant.muted,
                      ),
                    ),

                  // Product name
                  Text(
                    product.name,
                    style: AppTextStyles.h1.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),

                  // Rating
                  if (product.rating > 0)
                    Row(
                      children: [
                        RatingStars(
                          rating: product.rating,
                          size: 16,
                          showCount: true,
                          reviewCount: product.reviewCount,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '· ${product.reviewCount} reviews',
                          style: AppTextStyles.bodyXs
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        Formatters.price(
                            product.discountPrice ?? product.price),
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 28,
                          color: product.hasDiscount
                              ? AppColors.primary
                              : AppColors.text,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 12),
                        Text(
                          Formatters.price(product.price),
                          style: AppTextStyles.body.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            '-${product.discountPercent}%',
                            style: AppTextStyles.bodyXs.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stock status
                  _buildStockBadge(product),
                  const SizedBox(height: 16),

                  // Description
                  if (product.description != null) ...[
                    Text(
                      product.description!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  // Quantity selector
                  Row(
                    children: [
                      Text('Quantity:',
                          style: AppTextStyles.bodySm
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 16),
                      _buildQtyStepper(product),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // CTA buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: product.isInStock
                              ? '🛒 Add to Cart'
                              : 'Out of Stock',
                          onPressed: product.isInStock
                              ? () {
                                  ref.read(cartProvider.notifier).addItem(
                                    CartItem(
                                      productId: product.id,
                                      name: product.name,
                                      slug: product.slug,
                                      price: product.price,
                                      discountPrice: product.discountPrice,
                                      imageUrl: product.primaryImage,
                                      storeName: product.storeName ?? 'GiftsWale',
                                      stock: product.stock,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${product.name} added to cart!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              : null,
                          isFullWidth: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // TODO: Phase 5 — wishlist
                          },
                          icon: const Icon(Icons.favorite_border_rounded,
                              color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Buy Now
                  if (product.isInStock)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).addItem(
                            CartItem(
                              productId: product.id,
                              name: product.name,
                              slug: product.slug,
                              price: product.price,
                              discountPrice: product.discountPrice,
                              imageUrl: product.primaryImage,
                              storeName: product.storeName ?? 'GiftsWale',
                              stock: product.stock,
                            ),
                          );
                          context.go('/cart');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                        ),
                        child: Text(
                          '⚡ Buy Now',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Store card
                  if (product.storeName != null)
                    GestureDetector(
                      onTap: () {
                        if (product.storeSlug != null) {
                          context.push('/store/${product.storeSlug}');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.bgElevated,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd),
                              ),
                              child: const Center(
                                child: Text('🏪',
                                    style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.storeName!,
                                    style: AppTextStyles.bodySm.copyWith(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'View Store →',
                                    style: AppTextStyles.bodyXs.copyWith(
                                        color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textMuted, size: 20),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Image gallery with thumbnails
  Widget _buildImageGallery(Product product) {
    final images = product.images;
    if (images.isEmpty) {
      return Container(
        color: AppColors.bgSurface,
        child: const Center(
          child: Text('🎁', style: TextStyle(fontSize: 80)),
        ),
      );
    }

    return Stack(
      children: [
        // Main image
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (index) =>
              setState(() => _activeImageIndex = index),
          itemBuilder: (context, index) => CachedImage(
            imageUrl: images[index],
            fit: BoxFit.cover,
          ),
        ),
        // Image counter
        if (images.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_activeImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        // Discount badge
        if (product.hasDiscount)
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                '${product.discountPercent}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStockBadge(Product product) {
    if (product.stock == 0) {
      return const BadgeWidget(
          label: 'Out of Stock', variant: BadgeVariant.danger);
    } else if (product.stock <= 5) {
      return BadgeWidget(
          label: '⚡ Only ${product.stock} left!',
          variant: BadgeVariant.warning);
    } else {
      return const BadgeWidget(
          label: '✓ In Stock', variant: BadgeVariant.success);
    }
  }

  Widget _buildQtyStepper(Product product) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyButton(
            icon: Icons.remove,
            onTap: _qty > 1 ? () => setState(() => _qty--) : null,
          ),
          Container(
            width: 44,
            alignment: Alignment.center,
            child: Text(
              '$_qty',
              style: AppTextStyles.bodySm
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _qtyButton(
            icon: Icons.add,
            onTap: _qty < product.stock
                ? () => setState(() => _qty++)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppColors.text : AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _circleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: AppColors.shadowSm,
          ),
          child: Icon(icon, size: 18, color: AppColors.text),
        ),
      ),
    );
  }
}
