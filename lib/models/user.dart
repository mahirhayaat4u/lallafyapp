/// User model — mirrors the user object returned from the backend
///
/// 💡 React Native equivalent: This is like defining a TypeScript interface,
/// but in Dart we create a class with fromJson/toJson methods.
/// The web version uses a simple `interface User` in authStore.ts;
/// in Flutter/Dart we need explicit serialization.
class User {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String? phone;

  const User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
  });

  /// Create User from JSON response
  /// Backend returns: { userId, name, email, role, phone }
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
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
    };
  }

  /// Create a copy with modified fields
  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
  }) {
    return User(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isVendor => role == 'vendor';
  bool get isCustomer => role == 'customer';

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
