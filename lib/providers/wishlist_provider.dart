import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/product.dart';

/// Wishlist state — keeps track of wishlisted product IDs locally
/// and syncs with backend API.
class WishlistState {
  final Set<String> productIds;
  final List<Product> products;
  final bool isLoading;

  const WishlistState({
    this.productIds = const {},
    this.products = const [],
    this.isLoading = false,
  });

  WishlistState copyWith({
    Set<String>? productIds,
    List<Product>? products,
    bool? isLoading,
  }) {
    return WishlistState(
      productIds: productIds ?? this.productIds,
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isWishlisted(String productId) => productIds.contains(productId);
}

class WishlistNotifier extends StateNotifier<WishlistState> {
  final DioClient _dio;

  WishlistNotifier(this._dio) : super(const WishlistState());

  /// Fetch wishlist from API
  Future<void> fetchWishlist() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _dio.get(ApiConstants.wishlist);
      final data = response.data;

      // Backend returns array of products directly
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else {
        list = data['wishlist'] ?? data['items'] ?? data['data'] ?? [];
      }

      final products = list.map((item) {
        if (item is Map<String, dynamic>) {
          // Could be {product: {...}} or directly a product object
          final productData = item['product'] ?? item;
          return Product.fromJson(productData as Map<String, dynamic>);
        }
        return Product.fromJson(item as Map<String, dynamic>);
      }).toList();

      final ids = products.map((p) => p.id).toSet();

      state = WishlistState(
        productIds: ids,
        products: products,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Toggle wishlist item (add or remove)
  Future<void> toggle(Product product) async {
    final isCurrentlyWishlisted = state.isWishlisted(product.id);

    // Optimistic UI update
    if (isCurrentlyWishlisted) {
      state = state.copyWith(
        productIds: {...state.productIds}..remove(product.id),
        products: state.products.where((p) => p.id != product.id).toList(),
      );
    } else {
      state = state.copyWith(
        productIds: {...state.productIds, product.id},
        products: [...state.products, product],
      );
    }

    // Sync with backend
    try {
      await _dio.post(ApiConstants.wishlistItem(product.id));
    } catch (e) {
      // Revert on failure
      if (isCurrentlyWishlisted) {
        state = state.copyWith(
          productIds: {...state.productIds, product.id},
          products: [...state.products, product],
        );
      } else {
        state = state.copyWith(
          productIds: {...state.productIds}..remove(product.id),
          products: state.products.where((p) => p.id != product.id).toList(),
        );
      }
    }
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier(DioClient());
});
