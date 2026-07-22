/// Banner model — mirrors the hero banner cards from HomePage.tsx
class Banner {
  final String id;
  final String? label;
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final String imageUrl;
  final String bgColor;
  final String? buttonColor;
  final String? textColor;
  final String? btnTextColor;
  final String? link;
  final bool isImageOnly;

  const Banner({
    required this.id,
    this.label,
    this.title,
    this.subtitle,
    this.buttonText,
    required this.imageUrl,
    this.bgColor = '#f2ece4',
    this.buttonColor,
    this.textColor,
    this.btnTextColor,
    this.link,
    this.isImageOnly = false,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    final mediaUrl = (json['media'] ?? json['imageUrl'] ?? json['image'] ?? '').toString();
    final hasTitle = (json['title'] as String?)?.isNotEmpty == true;
    final hasLabel = (json['label'] as String?)?.isNotEmpty == true;

    String? finalLink = json['link'] as String?;
    if (finalLink == null || finalLink.isEmpty) {
      if (json['category'] != null) {
        if (json['category'] is Map) {
          final slug = json['category']['slug']?.toString();
          if (slug != null && slug.isNotEmpty) {
            finalLink = '/shop?category=$slug';
          } else {
            final id = (json['category']['_id'] ?? json['category']['id'])?.toString();
            if (id != null && id.isNotEmpty) {
              finalLink = '/shop?category=$id';
            }
          }
        } else {
          finalLink = '/shop?category=${json['category']}';
        }
      }
    }

    return Banner(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      label: json['label'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      buttonText: json['buttonText'] as String?,
      imageUrl: mediaUrl,
      bgColor: json['bgColor'] as String? ?? '#f2ece4',
      buttonColor: json['buttonColor'] as String?,
      textColor: json['textColor'] as String?,
      btnTextColor: json['btnTextColor'] as String?,
      link: finalLink,
      isImageOnly: json['isImageOnly'] as bool? ?? (!hasTitle && !hasLabel),
    );
  }
}
