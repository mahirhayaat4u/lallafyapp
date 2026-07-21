import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../models/cart_item.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../providers/auth_provider.dart';

/// Product Card widget — matching exact design from screenshot:
/// - Rounded card with top-left badge ("Best Seller" / "Trending" / "% OFF")
/// - Circular top-right wishlist heart icon
/// - Square floating product image
/// - Product title (Bold Outfit font)
/// - Selling price (Pink), Original strikethrough price (Grey), and Green OFF tag
/// - Rating stars (Gold) + Floating pink Add-to-Cart circular button
class ProductCard extends ConsumerStatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width = double.infinity,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartNotifier = ref.read(cartProvider.notifier);

    // Price & Discount calculations from model
    final double sellingPrice = product.sellingPrice;
    final double originalPrice = product.originalPrice;
    final int discountPercent = product.discountPercent;

    // Badge label logic
    String? badgeLabel;
    if (product.isBestSeller) {
      badgeLabel = 'Best Seller';
    } else if (product.isFeatured) {
      badgeLabel = 'Trending';
    } else if (discountPercent > 0) {
      badgeLabel = '$discountPercent% OFF';
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Image & Overlay Badges Area ──
            AspectRatio(
              aspectRatio: 1.05,
              child: Stack(
                children: [
                  // Center Image
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: CachedImage(
                        imageUrl: product.primaryImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Top-Left Badge ("Best Seller" / "Trending")
                  if (badgeLabel != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF448C),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF448C).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          badgeLabel,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: Builder(
                      builder: (context) {
                        final wishlist = ref.watch(wishlistProvider);
                        final isWishlisted = wishlist.isWishlisted(product.id);

                        return GestureDetector(
                          onTap: () {
                            final auth = ref.read(authProvider);
                            if (!auth.isAuthenticated) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please login to add to wishlist'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            ref.read(wishlistProvider.notifier).toggle(product);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isWishlisted
                                      ? 'Removed from wishlist'
                                      : 'Added to wishlist ❤️',
                                ),
                                backgroundColor: isWishlisted
                                    ? Colors.grey
                                    : const Color(0xFFFF448C),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 18,
                              color: isWishlisted
                                  ? const Color(0xFFFF448C)
                                  : const Color(0xFF1A1C23),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Product Details Area ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Title
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1C23),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Price Row: ₹299  ₹499  40% OFF
                    Row(
                      children: [
                        Text(
                          '₹${sellingPrice.toInt()}',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF448C),
                          ),
                        ),
                        if (originalPrice > sellingPrice) ...[
                          const SizedBox(width: 5),
                          Text(
                            '₹${originalPrice.toInt()}',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9E9E9E),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        if (discountPercent > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '$discountPercent% OFF',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00C853),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Bottom Row: Rating Stars (Left) + Pink Floating Cart Button (Right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating stars & review count from actual DB
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < (product.rating > 0 ? product.rating.round() : 5)
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 13,
                                  color: index < (product.rating > 0 ? product.rating.round() : 5)
                                      ? const Color(0xFFFFC107)
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${product.reviewCount})',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),

                        // Pink Floating Add to Cart Button
                        GestureDetector(
                          onTap: () {
                            cartNotifier.addItem(
                              CartItem(
                                productId: product.id,
                                name: product.name,
                                slug: product.slug,
                                price: product.originalPrice,
                                discountPrice: product.sellingPrice,
                                imageUrl: product.primaryImage,
                                stock: product.stock,
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
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF448C),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF448C).withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
