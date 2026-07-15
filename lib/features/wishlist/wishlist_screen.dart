import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/product.dart';
import '../home/widgets/product_card.dart';

/// Wishlist provider — fetches from API
final wishlistProvider = FutureProvider<List<Product>>((ref) async {
  final response = await DioClient().get(ApiConstants.wishlist);
  final data = response.data;
  final list = data['wishlist'] ?? data['items'] ?? data['data'] ?? [];
  return (list as List<dynamic>).map((item) {
    final product = item['product'] ?? item;
    return Product.fromJson(product as Map<String, dynamic>);
  }).toList();
});

/// Wishlist Screen — mirrors WishlistPage.tsx
///
/// Shows saved products in a 2-column grid. Requires auth.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        title: const Text('❤️ My Wishlist'),
      ),
      body: wishlistAsync.when(
        data: (products) {
          if (products.isEmpty) return _buildEmpty(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  '${products.length} items saved',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => ProductCard(
                    product: products[index],
                    width: double.infinity,
                    onTap: () {
                      context.push('/product/${products[index].slug}');
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Loading wishlist...'),
        error: (err, _) => _buildEmpty(context),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('❤️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Your wishlist is empty', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Save gifts you love to your wishlist and come back later.',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => context.push('/shop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
                child: Text(
                  'Discover Gifts',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
