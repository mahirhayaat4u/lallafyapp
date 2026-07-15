/// Category model (supports parent-child tree structure)
class Category {
  final String id;
  final String name;
  final String slug;
  final String? imageUrl;
  final int productCount;
  final List<Category> children;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.productCount = 0,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      imageUrl: json['imageUrl'] as String?,
      productCount: json['_count']?['products'] as int? ?? 0,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
