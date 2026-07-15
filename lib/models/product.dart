/// Product model — mirrors the product schema from Prisma
class Product {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String? categoryId;
  final String? categoryName;
  final String? storeName;
  final String? storeSlug;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final int stock;
  final List<String> tags;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    this.categoryId,
    this.categoryName,
    this.storeName,
    this.storeSlug,
    this.rating = 0,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.stock = 0,
    this.tags = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Images can be objects [{url: "..."}] or strings
    final rawImages = json['images'] as List<dynamic>? ?? [];
    final images = rawImages.map((e) {
      if (e is Map) return e['url']?.toString() ?? '';
      return e.toString();
    }).where((url) => url.isNotEmpty).toList();

    // Price can come as string or number
    final price = json['price'] is String
        ? double.parse(json['price'])
        : (json['price'] as num).toDouble();
    final discountRaw = json['discountPrice'];
    final discountPrice = discountRaw != null
        ? (discountRaw is String ? double.parse(discountRaw) : (discountRaw as num).toDouble())
        : null;

    return Product(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      price: price,
      discountPrice: discountPrice,
      images: images,
      categoryId: json['categoryId'] as String?,
      categoryName: json['category']?['name'] as String?,
      storeName: json['store']?['storeName'] as String? ?? json['store']?['name'] as String?,
      storeSlug: json['store']?['slug'] as String?,
      rating: (json['avgRating'] is String
          ? double.tryParse(json['avgRating']) ?? 0
          : (json['avgRating'] as num?)?.toDouble()) ?? 0,
      reviewCount: json['reviewCount'] as int? ?? json['_count']?['reviews'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      stock: json['stock'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String get primaryImage => images.isNotEmpty ? images.first : '';
  bool get hasDiscount =>
      discountPrice != null && discountPrice! < price;
  bool get isInStock => stock > 0;
  int get discountPercent => hasDiscount
      ? ((price - discountPrice!) / price * 100).round()
      : 0;
}
