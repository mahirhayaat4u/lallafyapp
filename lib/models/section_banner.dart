/// SectionBanner model — maps to Mongoose SectionBanner schema from lallafy.com
class SectionBanner {
  final String id;
  final String section;
  final String image;
  final String? categoryId;
  final String? categoryName;
  final String? title;

  const SectionBanner({
    required this.id,
    required this.section,
    required this.image,
    this.categoryId,
    this.categoryName,
    this.title,
  });

  factory SectionBanner.fromJson(Map<String, dynamic> json) {
    String? catId;
    String? catName;
    if (json['category'] is Map) {
      catId = (json['category']['_id'] ?? json['category']['id'])?.toString();
      catName = json['category']['name']?.toString();
    } else if (json['category'] != null) {
      catId = json['category'].toString();
    }

    return SectionBanner(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      section: json['section'] as String? ?? '',
      image: json['image'] as String? ?? '',
      categoryId: catId,
      categoryName: catName,
      title: json['title'] as String?,
    );
  }
}
