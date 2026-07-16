/// AgeGroup model — maps to lallafy.com Mongoose AgeGroup schema
class AgeGroup {
  final String id;
  final String label;
  final String? image;
  final String emoji;
  final String bgColor;
  final String borderColor;
  final String textColor;
  final int order;

  const AgeGroup({
    required this.id,
    required this.label,
    this.image,
    this.emoji = '🧸',
    this.bgColor = '#F3F4F6',
    this.borderColor = '#9CA3AF',
    this.textColor = '#1F2937',
    this.order = 0,
  });

  factory AgeGroup.fromJson(Map<String, dynamic> json) {
    return AgeGroup(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      label: json['label'] as String? ?? '',
      image: json['image'] as String?,
      emoji: json['emoji'] as String? ?? '🧸',
      bgColor: json['bgColor'] as String? ?? '#F3F4F6',
      borderColor: json['borderColor'] as String? ?? '#9CA3AF',
      textColor: json['textColor'] as String? ?? '#1F2937',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}
