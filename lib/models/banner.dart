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
    return Banner(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      label: json['label'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      buttonText: json['buttonText'] as String?,
      imageUrl: json['imageUrl'] as String? ?? json['image'] as String? ?? '',
      bgColor: json['bgColor'] as String? ?? '#f2ece4',
      buttonColor: json['buttonColor'] as String?,
      textColor: json['textColor'] as String?,
      btnTextColor: json['btnTextColor'] as String?,
      link: json['link'] as String?,
      isImageOnly: json['isImageOnly'] as bool? ?? false,
    );
  }
}
