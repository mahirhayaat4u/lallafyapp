/// Gifting Story model for Instagram-style stories section
class GiftingStory {
  final String id;
  final String name;
  final String btnLabel;
  final String views;
  final String coverImageUrl;
  final String? videoUrl;
  final String caption;
  final String link;

  const GiftingStory({
    required this.id,
    required this.name,
    required this.btnLabel,
    required this.views,
    required this.coverImageUrl,
    this.videoUrl,
    required this.caption,
    required this.link,
  });

  factory GiftingStory.fromJson(Map<String, dynamic> json) {
    return GiftingStory(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      btnLabel: json['btnLabel'] as String? ?? 'SHOP NOW',
      views: json['views'] as String? ?? '0',
      coverImageUrl: json['coverImageUrl'] as String? ?? json['image'] as String? ?? '',
      videoUrl: json['videoUrl'] as String?,
      caption: json['caption'] as String? ?? '',
      link: json['link'] as String? ?? '/shop',
    );
  }
}
