import 'product.dart';

/// Review Model — maps to Mongoose Review schema from lallafy.com
class Review {
  final String id;
  final double rating;
  final String comment;
  final String userName;
  final String? userAvatar;
  final Product? product;
  final DateTime? createdAt;

  final String? title;
  final List<String> images;

  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.userName,
    this.title,
    this.images = const [],
    this.userAvatar,
    this.product,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    String name = 'Verified Customer';
    String? avatar;

    if (json['user'] is Map) {
      final u = json['user'] as Map<String, dynamic>;
      name = u['name']?.toString() ?? name;
      avatar = u['avatar']?.toString();
    } else if (json['guestName'] != null && json['guestName'].toString().isNotEmpty) {
      name = json['guestName'].toString();
    }

    Product? prod;
    if (json['product'] is Map) {
      prod = Product.fromJson(json['product'] as Map<String, dynamic>);
    }

    final ratingRaw = json['rating'];
    final rating = ratingRaw is String
        ? (double.tryParse(ratingRaw) ?? 5.0)
        : ((ratingRaw as num?)?.toDouble() ?? 5.0);

    final rawImgs = json['images'] as List<dynamic>? ?? [];
    final images = rawImgs.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();

    return Review(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      rating: rating,
      comment: json['comment']?.toString() ?? '',
      userName: name,
      title: json['title']?.toString(),
      images: images,
      userAvatar: avatar,
      product: prod,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  String get initials {
    final parts = userName.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
