/// Cart item model — mirrors useCartStore item from cartStore.ts
class CartItem {
  final String productId;
  final String name;
  final String slug;
  final double price;
  final double? discountPrice;
  final String? imageUrl;
  final String? storeId;
  final String storeName;
  final int stock;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.slug,
    required this.price,
    this.discountPrice,
    this.imageUrl,
    this.storeId,
    this.storeName = 'GiftsWale',
    this.stock = 99,
    this.quantity = 1,
  });

  double get effectivePrice => discountPrice ?? price;
  double get lineTotal => effectivePrice * quantity;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      slug: slug,
      price: price,
      discountPrice: discountPrice,
      imageUrl: imageUrl,
      storeId: storeId,
      storeName: storeName,
      stock: stock,
      quantity: quantity ?? this.quantity,
    );
  }
}
