/// Occasion Tab model for "Tailored For Your Occasions" section
class OccasionTab {
  final String id;
  final String name;
  final String? icon;
  final String? productIds;

  const OccasionTab({
    required this.id,
    required this.name,
    this.icon,
    this.productIds,
  });

  factory OccasionTab.fromJson(Map<String, dynamic> json) {
    return OccasionTab(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      productIds: json['productIds'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OccasionTab &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

