/// Product model — mirrors the product schema from Prisma
class Product {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final List<String> descriptionImages;
  final List<Map<String, String>> specifications;
  final String? categoryId;
  final String? categoryName;
  final String? storeName;
  final String? storeSlug;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isBestSeller;
  final bool isGifting;
  final bool isSkillDevelopment;
  final bool isMusical;
  final String? bestSellerVideo;
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
    this.descriptionImages = const [],
    this.specifications = const [],
    this.categoryId,
    this.categoryName,
    this.storeName,
    this.storeSlug,
    this.rating = 0,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.isGifting = false,
    this.isSkillDevelopment = false,
    this.isMusical = false,
    this.bestSellerVideo,
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

    final rawDescImages = json['descriptionImages'] as List<dynamic>? ?? [];
    final descriptionImages = rawDescImages.map((e) {
      if (e is Map) return e['url']?.toString() ?? '';
      return e.toString();
    }).where((url) => url.isNotEmpty).toList();

    final rawSpecs = json['specifications'] as List<dynamic>? ?? [];
    final specifications = rawSpecs.map((e) {
      if (e is Map) {
        return {
          'key': (e['key'] ?? e['name'] ?? '').toString(),
          'value': (e['value'] ?? '').toString(),
        };
      }
      return {'key': '', 'value': e.toString()};
    }).where((s) => s['key']!.isNotEmpty || s['value']!.isNotEmpty).toList();

    // Support both lallafy.com Mongoose (price, sellingPrice) and Prisma schemas
    final rawPrice = json['sellingPrice'] ?? json['discountPrice'] ?? json['price'] ?? 0;
    final rawMrp = json['price'] ?? json['mrp'] ?? json['originalPrice'];

    final price = rawPrice is String
        ? double.parse(rawPrice)
        : (rawPrice as num).toDouble();

    final discountPrice = rawMrp != null
        ? (rawMrp is String ? double.parse(rawMrp) : (rawMrp as num).toDouble())
        : null;

    final avgRating = json['ratingsAverage'] ?? json['avgRating'] ?? 0;
    final revCount = json['ratingsCount'] ?? json['reviewCount'] ?? json['_count']?['reviews'] ?? 0;

    return Product(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? 'Product',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      price: price,
      discountPrice: discountPrice,
      images: images,
      descriptionImages: descriptionImages,
      specifications: specifications,
      categoryId: json['categoryId'] as String?,
      categoryName: json['category']?['name'] as String?,
      storeName: json['store']?['storeName'] as String? ?? json['store']?['name'] as String?,
      storeSlug: json['store']?['slug'] as String?,
      rating: (avgRating is String
          ? double.tryParse(avgRating) ?? 0
          : (avgRating as num).toDouble()),
      reviewCount: (revCount is String
          ? int.tryParse(revCount) ?? 0
          : (revCount as num).toInt()),
      isFeatured: json['isFeatured'] as bool? ?? false,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
      isGifting: json['isGifting'] as bool? ?? false,
      isSkillDevelopment: json['isSkillDevelopment'] as bool? ?? false,
      isMusical: json['isMusical'] as bool? ?? false,
      bestSellerVideo: json['bestSellerVideo'] as String?,
      stock: json['stock'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String get primaryImage => images.isNotEmpty ? images.first : '';
  double get sellingPrice => price;
  double get originalPrice => (discountPrice != null && discountPrice! > price)
      ? discountPrice!
      : price;
  bool get hasDiscount =>
      discountPrice != null && discountPrice! > price;
  bool get isInStock => stock > 0;
  int get discountPercent => hasDiscount
      ? ((originalPrice - price) / originalPrice * 100).round()
      : 0;
}
