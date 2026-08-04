import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

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
import '../../models/review.dart';
import '../../providers/cart_provider.dart';
import '../../providers/homepage_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../home/widgets/product_card.dart';

class ProductDetailState {
  final Product product;
  final List<Product> relatedProducts;

  const ProductDetailState({
    required this.product,
    this.relatedProducts = const [],
  });
}

/// Product detail provider — fetches product & related products by id or slug
final productDetailProvider =
    FutureProvider.family<ProductDetailState, String>((ref, idOrSlug) async {
  final response = await DioClient().get(ApiConstants.productById(idOrSlug));
  final data = response.data;
  final Map<String, dynamic> rootMap =
      (data is Map) ? Map<String, dynamic>.from(data) : {};

  final productJson = rootMap['product'] ??
      rootMap['data']?['product'] ??
      rootMap['data'] ??
      rootMap;
  final product =
      Product.fromJson(Map<String, dynamic>.from(productJson as Map));

  final rawRelated = rootMap['relatedProducts'] as List<dynamic>? ?? [];
  final relatedProducts = rawRelated
      .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  return ProductDetailState(
    product: product,
    relatedProducts: relatedProducts,
  );
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
  final GlobalKey _reviewsKey = GlobalKey();
  int _activeImageIndex = 0;
  int _qty = 1;

  void _scrollToReviews() {
    final ctx = _reviewsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(productDetailProvider(widget.slug));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: detailAsync.when(
        data: (state) => _buildProductDetail(state.product, state.relatedProducts),
        loading: () => const LoadingWidget(message: 'Loading product...'),
        error: (err, _) => _buildError(err.toString()),
      ),
      bottomNavigationBar: detailAsync.when(
        data: (state) => _buildStickyBottomBar(context, state.product),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
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
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail(Product product, List<Product> relatedProducts) {
    return CustomScrollView(
      slivers: [
        // ── Sticky Pinned Top Header Bar (Pastel pink tint + Logo + Cart Badge) ──
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            topPadding: MediaQuery.of(context).padding.top,
            child: _buildTopHeaderBar(context, product),
          ),
        ),

        // ── Product Image Card with Rounded Top ──
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFFFFF2F5),
            child: Container(
              height: MediaQuery.of(context).size.width * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildImageGallery(product),
            ),
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

                  // Rating (Tappable to smooth-scroll down to Customer Reviews)
                  if (product.rating > 0)
                    GestureDetector(
                      onTap: _scrollToReviews,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                            style: AppTextStyles.bodyXs.copyWith(
                              color: AppColors.textMuted,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        Formatters.price(product.sellingPrice),
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
                          Formatters.price(product.originalPrice),
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
                  if (product.description != null &&
                      product.description!.trim().isNotEmpty) ...[
                    _buildDescription(product.description!),
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
                  const SizedBox(height: 20),

                  // Saved Delivery Address Bar with Change option
                  _DeliveryAddressSection(product: product),
                  const SizedBox(height: 24),

                  const SizedBox(height: 16),

                  // Specifications Section
                  if (product.specifications.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSpecifications(product),
                  ],

                  // Description Images Section (Rich Product Features Gallery)
                  if (product.descriptionImages.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDescriptionImages(product),
                  ],

                  // Store card
                  if (product.storeName != null) ...[
                    const SizedBox(height: 24),
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
                  ],

                  // Customer Reviews Section
                  const SizedBox(height: 28),
                  _buildReviewsSection(product),

                  // Similar Products Section
                  if (relatedProducts.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSimilarProducts(context, relatedProducts),
                  ],
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
            fit: BoxFit.contain,
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
            top: 16,
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

  /// Top Header Bar matching user mockup (Pastel Pink + White Back button + Centered Logo + Wishlist/Cart Badge/Share)
  Widget _buildTopHeaderBar(BuildContext context, Product product) {
    final cartState = ref.watch(cartProvider);
    final itemCount = cartState.totalItems;
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.isWishlisted(product.id);

    return Container(
      color: const Color(0xFFFFF2F5),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Centered Brand Logo (absolute center, independent of buttons)
              Center(
                child: Image.asset(
                  'assets/images/lallafy.png',
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Lallafy',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF448C),
                      ),
                    );
                  },
                ),
              ),

              // Left: Back button
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF1F2937),
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Right: Wishlist, Cart with Badge, Share
              Positioned(
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Wishlist Icon
                    IconButton(
                      onPressed: () {
                        final auth = ref.read(authProvider);
                        if (!auth.isAuthenticated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please login to add to wishlist'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          context.push('/login');
                          return;
                        }
                        ref.read(wishlistProvider.notifier).toggle(product);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isWishlisted
                                  ? '${product.name} removed from wishlist'
                                  : '${product.name} added to wishlist ❤️',
                            ),
                            backgroundColor: isWishlisted
                                ? Colors.grey
                                : const Color(0xFFFF448C),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(
                        isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isWishlisted
                            ? const Color(0xFFFF448C)
                            : const Color(0xFF1F2937),
                        size: 22,
                      ),
                    ),

                    // Cart Icon with Badge Counter
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () => context.push('/cart'),
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Color(0xFF1F2937),
                            size: 22,
                          ),
                        ),
                        if (itemCount > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF448C),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$itemCount',
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

                    // Share Icon
                    IconButton(
                      onPressed: () {
                        Share.share(
                          'Check out ${product.name} on Lallafy!\n\nhttps://lallafy.com/product/${product.slug ?? product.id}',
                          subject: 'Share Product',
                        );
                      },
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Color(0xFF1F2937),
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  /// Sticky Bottom Navigation Bar — persistent CTA buttons fixed at bottom of screen
  Widget _buildStickyBottomBar(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(
          top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Add to Cart / Go to Cart Button
              Expanded(
                child: Builder(
                  builder: (context) {
                    final cart = ref.watch(cartProvider);
                    final isInCart = cart.items.any((i) => i.productId == product.id);

                    if (isInCart) {
                      // Go to Cart Button (Green)
                      return ElevatedButton(
                        onPressed: () => context.push('/cart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Go to Cart',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Add to Cart Button (Pink)
                    return ElevatedButton(
                      onPressed: product.isInStock
                          ? () {
                              ref.read(cartProvider.notifier).addItem(
                                    CartItem(
                                      productId: product.id,
                                      name: product.name,
                                      slug: product.slug,
                                      price: product.originalPrice,
                                      discountPrice: product.sellingPrice,
                                      imageUrl: product.primaryImage,
                                      storeName: product.storeName ?? 'Lallafy',
                                      stock: product.stock,
                                      quantity: _qty,
                                    ),
                                  );
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart! 🛒'),
                                  backgroundColor: const Color(0xFFFF448C),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF448C),
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            product.isInStock ? 'Add to Cart' : 'Out of Stock',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              if (product.isInStock) ...[
                const SizedBox(width: 12),

                // Buy Now Button (Dark Solid)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).addItem(
                            CartItem(
                              productId: product.id,
                              name: product.name,
                              slug: product.slug,
                              price: product.originalPrice,
                              discountPrice: product.sellingPrice,
                              imageUrl: product.primaryImage,
                              storeName: product.storeName ?? 'Lallafy',
                              stock: product.stock,
                              quantity: _qty,
                            ),
                          );
                      context.push('/cart');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1C23),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('⚡ ', style: TextStyle(fontSize: 14)),
                        Text(
                          'Buy Now',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Product Description Section — renders rich HTML formatting (bold, lists, colors, headers)
  Widget _buildDescription(String rawDescription) {
    if (rawDescription.trim().isEmpty) return const SizedBox.shrink();

    final hasHtml = RegExp(r'<[a-z][\s\S]*>', caseSensitive: false).hasMatch(rawDescription);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Description',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        hasHtml
            ? _HtmlContentRenderer(htmlContent: rawDescription)
            : Text(
                rawDescription.trim(),
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4B5563),
                  height: 1.6,
                ),
              ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Specifications list
  Widget _buildSpecifications(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specifications',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          ...product.specifications.map((spec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        spec['key'] ?? '',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        spec['value'] ?? '',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Description Images Gallery (matches Website ProductDetail layout)
  Widget _buildDescriptionImages(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Overview & Features',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        ...product.descriptionImages.map(
          (imageUrl) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedImage(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Customer Reviews Section (matches Website Customer Reviews)
  Widget _buildReviewsSection(Product product) {
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));

    return Container(
      key: _reviewsKey,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.reviewCount} total ratings',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),

              // Rating Score Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFC107)),
                    const SizedBox(width: 4),
                    Text(
                      product.rating > 0 ? product.rating.toStringAsFixed(1) : '5.0',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 16),

          // Reviews Async Content
          reviewsAsync.when(
            data: (reviews) {
              if (reviews.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No reviews yet. Be the first to review this product! ⭐',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                );
              }

              final allReviewImages = reviews.expand((r) => r.images).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Photos Strip (if any review images exist)
                  if (allReviewImages.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Customer Photos (${allReviewImages.length})',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openImageGalleryModal(context, allReviewImages, 0),
                          child: const Text(
                            'View All →',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF448C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: allReviewImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          return GestureDetector(
                            onTap: () => _openImageGalleryModal(context, allReviewImages, idx),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedImage(
                                imageUrl: allReviewImages[idx],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF3F4F6), height: 1),
                    const SizedBox(height: 16),
                  ],

                  ...reviews.map((rev) => _buildReviewCard(rev, allReviewImages)).toList(),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFFFF448C)),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Single Customer Review Card
  Widget _buildReviewCard(Review review, List<String> allReviewImages) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar + Name + Rating Stars
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFFFE4E6),
                backgroundImage: review.userAvatar != null ? NetworkImage(review.userAvatar!) : null,
                child: review.userAvatar == null
                    ? Text(
                        review.initials,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF448C),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 13,
                          color: index < review.rating.round()
                              ? const Color(0xFFFFC107)
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (review.createdAt != null)
                Text(
                  '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),

          // Title / Headline
          if (review.title != null && review.title!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.title!,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ],

          // Comment
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF4B5563),
              ),
            ),
          ],

          // Attached Photos (if any)
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final targetList = allReviewImages.isNotEmpty ? allReviewImages : review.images;
                  final startIdx = targetList.contains(review.images[idx])
                      ? targetList.indexOf(review.images[idx])
                      : idx;
                  return GestureDetector(
                    onTap: () => _openImageGalleryModal(context, targetList, startIdx),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedImage(
                        imageUrl: review.images[idx],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Similar Products Section — matches website related products section
  Widget _buildSimilarProducts(
      BuildContext context, List<Product> relatedProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Similar Products',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/explore'),
              child: const Text(
                'View All →',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF448C),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 285,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = relatedProducts[index];
              return ProductCard(
                product: item,
                width: 165,
                onTap: () {
                  context.push('/product/${item.id}');
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openImageGalleryModal(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    if (images.isEmpty) return;

    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => _ImageGalleryViewer(
        images: images,
        initialIndex: initialIndex,
      ),
    );
  }
}

/// Persistent header delegate for keeping top navigation sticky on scroll
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double topPadding;

  _StickyHeaderDelegate({required this.child, required this.topPadding});

  @override
  double get minExtent => topPadding + 56;

  @override
  double get maxExtent => topPadding + 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.topPadding != topPadding;
  }
}

/// Fullscreen Swipeable Customer Photo Gallery Viewer
class _ImageGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageGalleryViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<_ImageGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Swipeable Fullscreen Image PageView
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                );
              },
            ),

            // Top Header: Close Button & Image Counter
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Counter Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Thumbnail Selector Bar
            if (widget.images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final isSelected = idx == _currentIndex;
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            idx,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF448C) : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedImage(
                              imageUrl: widget.images[idx],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// SAVED DELIVERY ADDRESS WIDGET WITH CHANGE OPTION
/// ─────────────────────────────────────────────────────────────────────────────
class _DeliveryAddressSection extends ConsumerStatefulWidget {
  final Product product;

  const _DeliveryAddressSection({required this.product});

  @override
  ConsumerState<_DeliveryAddressSection> createState() =>
      __DeliveryAddressSectionState();
}

class __DeliveryAddressSectionState
    extends ConsumerState<_DeliveryAddressSection> {
  bool _loading = false;
  Map<String, dynamic>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadUserDefaultAddress();
  }

  Future<void> _loadUserDefaultAddress() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) return;

    setState(() => _loading = true);
    try {
      final res = await DioClient().get(ApiConstants.addresses);
      final data = res.data;
      List<dynamic> addresses = [];
      if (data is List) {
        addresses = data;
      } else if (data is Map) {
        addresses = data['addresses'] ??
            (data['data'] is Map ? data['data']['addresses'] : null) ??
            data['data'] ??
            [];
      }
      if (addresses.isNotEmpty) {
        final defaultAddr = addresses.firstWhere(
          (a) => a['isDefault'] == true || a['default'] == true,
          orElse: () => addresses.first,
        );
        if (mounted) {
          setState(() {
            _selectedAddress = Map<String, dynamic>.from(defaultAddr as Map);
          });
        }
      }
    } catch (e) {
      debugPrint('Address fetch error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onChangeAddress() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      context.push('/login');
      return;
    }

    await context.push('/addresses');
    _loadUserDefaultAddress();
  }

  @override
  Widget build(BuildContext context) {
    final name = _selectedAddress?['name'] ?? '';
    final city = _selectedAddress?['city'] ?? '';
    final pincode = _selectedAddress?['pincode']?.toString() ??
        _selectedAddress?['zip']?.toString() ??
        '';
    final line1 = _selectedAddress?['address'] ??
        _selectedAddress?['line1'] ??
        '';
    final hasAddress = pincode.isNotEmpty || city.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD8E4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFFE91E63),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _loading
                ? const Text(
                    'Loading delivery address...',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAddress
                            ? 'Deliver to: ${name.isNotEmpty ? name : 'User'} - $pincode'
                            : 'Select Delivery Address',
                        style: AppTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasAddress
                            ? (line1.isNotEmpty ? '$line1, $city' : city)
                            : 'Add or select saved address for delivery',
                        style: AppTextStyles.bodyXs.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _onChangeAddress,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE91E63),
              side: const BorderSide(color: Color(0xFFE91E63), width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              hasAddress ? 'CHANGE' : 'ADD',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// RICH HTML CONTENT RENDERER WIDGET FOR FLUTTER
/// ─────────────────────────────────────────────────────────────────────────────
class _HtmlContentRenderer extends StatelessWidget {
  final String htmlContent;

  const _HtmlContentRenderer({required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    final blocks = _parseHtmlBlocks(htmlContent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        if (block.type == _BlockType.heading) {
          return Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: RichText(
              text: TextSpan(
                children: _parseInlineSpans(
                  block.text,
                  baseStyle: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: block.level == 1 ? 19 : (block.level == 2 ? 17 : 15),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          );
        } else if (block.type == _BlockType.listItem) {
          return Padding(
            padding: const EdgeInsets.only(left: 4, top: 3, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.bulletPrefix ?? '• ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF448C),
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _parseInlineSpans(
                        block.text,
                        baseStyle: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13.5,
                          color: Color(0xFF374151),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (block.type == _BlockType.blockquote) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F5),
              border: Border(left: BorderSide(color: Color(0xFFFF448C), width: 3)),
            ),
            child: RichText(
              text: TextSpan(
                children: _parseInlineSpans(
                  block.text,
                  baseStyle: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
          );
        } else {
          if (block.text.trim().isEmpty) return const SizedBox(height: 4);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: RichText(
              text: TextSpan(
                children: _parseInlineSpans(
                  block.text,
                  baseStyle: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4B5563),
                    height: 1.6,
                  ),
                ),
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  List<_HtmlBlock> _parseHtmlBlocks(String html) {
    List<_HtmlBlock> blocks = [];

    String clean = html.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

    final regex = RegExp(
      r'<(h[1-6]|p|blockquote|ul|ol|li)[^>]*>(.*?)</\1>',
      caseSensitive: false,
      dotAll: true,
    );

    final matches = regex.allMatches(clean);

    if (matches.isEmpty) {
      final lines = clean.split('\n');
      for (var l in lines) {
        if (l.trim().isNotEmpty) {
          blocks.add(_HtmlBlock(type: _BlockType.paragraph, text: l));
        }
      }
      return blocks;
    }

    for (final match in matches) {
      final tag = match.group(1)!.toLowerCase();
      final content = match.group(2) ?? '';

      if (tag.startsWith('h')) {
        final level = int.tryParse(tag.substring(1)) ?? 2;
        blocks.add(_HtmlBlock(type: _BlockType.heading, text: content, level: level));
      } else if (tag == 'blockquote') {
        blocks.add(_HtmlBlock(type: _BlockType.blockquote, text: content));
      } else if (tag == 'ul') {
        final liRegex = RegExp(r'<li[^>]*>(.*?)</li\s*>', caseSensitive: false, dotAll: true);
        final liMatches = liRegex.allMatches(content);
        for (final li in liMatches) {
          blocks.add(_HtmlBlock(type: _BlockType.listItem, text: li.group(1) ?? '', bulletPrefix: '• '));
        }
      } else if (tag == 'ol') {
        final liRegex = RegExp(r'<li[^>]*>(.*?)</li\s*>', caseSensitive: false, dotAll: true);
        final liMatches = liRegex.allMatches(content);
        int idx = 1;
        for (final li in liMatches) {
          blocks.add(_HtmlBlock(type: _BlockType.listItem, text: li.group(1) ?? '', bulletPrefix: '${idx++}. '));
        }
      } else if (tag == 'li') {
        blocks.add(_HtmlBlock(type: _BlockType.listItem, text: content, bulletPrefix: '• '));
      } else {
        blocks.add(_HtmlBlock(type: _BlockType.paragraph, text: content));
      }
    }

    return blocks;
  }

  List<TextSpan> _parseInlineSpans(String text, {required TextStyle baseStyle}) {
    List<TextSpan> spans = [];

    final tagRegex = RegExp(
      r'<(b|strong|i|em|u|s|strike|span)[^>]*>(.*?)</\1>|([^<]+)',
      caseSensitive: false,
      dotAll: true,
    );

    final matches = tagRegex.allMatches(text);

    if (matches.isEmpty) {
      spans.add(TextSpan(text: _stripTags(text), style: baseStyle));
      return spans;
    }

    for (final match in matches) {
      final tag = match.group(1)?.toLowerCase();
      final content = match.group(2);
      final plain = match.group(3);

      if (plain != null && plain.isNotEmpty) {
        spans.add(TextSpan(text: _decodeHtmlEntities(plain), style: baseStyle));
      } else if (tag != null && content != null) {
        TextStyle inlineStyle = baseStyle;
        if (tag == 'b' || tag == 'strong') {
          inlineStyle = inlineStyle.copyWith(fontWeight: FontWeight.bold);
        } else if (tag == 'i' || tag == 'em') {
          inlineStyle = inlineStyle.copyWith(fontStyle: FontStyle.italic);
        } else if (tag == 'u') {
          inlineStyle = inlineStyle.copyWith(decoration: TextDecoration.underline);
        } else if (tag == 's' || tag == 'strike') {
          inlineStyle = inlineStyle.copyWith(decoration: TextDecoration.lineThrough);
        }

        final rawFullMatch = match.group(0) ?? '';
        final colorMatch = RegExp(r'color:\s*([^;"]+)', caseSensitive: false).firstMatch(rawFullMatch);
        if (colorMatch != null) {
          final colorStr = colorMatch.group(1)!.trim().toLowerCase();
          final parsedColor = _parseCssColor(colorStr);
          if (parsedColor != null) {
            inlineStyle = inlineStyle.copyWith(color: parsedColor);
          }
        }

        spans.addAll(_parseInlineSpans(content, baseStyle: inlineStyle));
      }
    }

    return spans;
  }

  String _stripTags(String input) {
    return _decodeHtmlEntities(input.replaceAll(RegExp(r'<[^>]*>'), ''));
  }

  String _decodeHtmlEntities(String input) {
    return input
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  Color? _parseCssColor(String str) {
    if (str.startsWith('#')) {
      final hex = str.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      }
    } else if (str.startsWith('rgb')) {
      final match = RegExp(r'\d+').allMatches(str).toList();
      if (match.length >= 3) {
        final r = int.parse(match[0].group(0)!);
        final g = int.parse(match[1].group(0)!);
        final b = int.parse(match[2].group(0)!);
        return Color.fromRGBO(r, g, b, 1.0);
      }
    }
    return null;
  }
}

enum _BlockType { paragraph, heading, listItem, blockquote }

class _HtmlBlock {
  final _BlockType type;
  final String text;
  final int level;
  final String? bulletPrefix;

  _HtmlBlock({
    required this.type,
    required this.text,
    this.level = 2,
    this.bulletPrefix,
  });
}



