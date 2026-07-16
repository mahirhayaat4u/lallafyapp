/// User model — mirrors the user object returned from the backend
///
/// Maps to Mongoose User schema: { _id, name, email, role, phone, avatar, isActive }
class User {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? avatar;
  final bool isActive;

  const User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatar,
    this.isActive = true,
  });

  /// Create User from JSON response
  /// Backend returns: { _id, name, email, role, phone, avatar, isActive }
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: (json['userId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      phone: (json['phone'] as String?)?.isNotEmpty == true ? json['phone'] as String : null,
      avatar: (json['avatar'] as String?)?.isNotEmpty == true ? json['avatar'] as String : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'avatar': avatar,
      'isActive': isActive,
    };
  }

  /// Create a copy with modified fields
  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatar,
    bool? isActive,
  }) {
    return User(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isVendor => role == 'vendor';
  bool get isCustomer => role == 'customer';
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  @override
  String toString() => 'User($name, $email, $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
