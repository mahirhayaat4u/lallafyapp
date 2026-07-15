/// Homepage section card model (flowers, relationship, luxury, personalize, combo cards)
class HomepageCard {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? link;
  final String? bgColor;
  final int sortOrder;

  const HomepageCard({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.link,
    this.bgColor,
    this.sortOrder = 0,
  });

  factory HomepageCard.fromJson(Map<String, dynamic> json) {
    return HomepageCard(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      imageUrl: json['imageUrl'] as String? ?? json['image'] as String? ?? '',
      link: json['link'] as String?,
      bgColor: json['bgColor'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
