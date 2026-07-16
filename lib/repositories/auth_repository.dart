import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/user.dart';

/// Auth Repository — handles all auth-related API calls
///
/// 💡 React Native equivalent: This is like combining authStore.ts API calls
/// with the auth parts of client.ts. Each method maps 1:1 to a backend endpoint.
///
/// Web version does these calls inside the Zustand store actions;
/// in Flutter, we separate the API layer (repository) from the state layer (provider).
class AuthRepository {
  final DioClient _client = DioClient();

  /// POST /auth/login → { success, token, user }
  Future<({User user, String token})> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data;
    final token = (data['token'] ?? data['data']?['token'] ?? '').toString();
    final userJson = data['user'] ?? data['data']?['user'] ?? data;
    return (
      user: User.fromJson(Map<String, dynamic>.from(userJson as Map)),
      token: token,
    );
  }

  /// POST /auth/register → { success, token, user }
  Future<({User user, String token})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    final data = response.data;
    final token = (data['token'] ?? data['data']?['token'] ?? '').toString();
    final userJson = data['user'] ?? data['data']?['user'] ?? data;
    return (
      user: User.fromJson(Map<String, dynamic>.from(userJson as Map)),
      token: token,
    );
  }

  /// GET /auth/me → { user }
  Future<User> fetchMe() async {
    final response = await _client.get(ApiConstants.me);
    final data = response.data;
    final userJson = data['user'] ?? data['data']?['user'] ?? data;
    return User.fromJson(Map<String, dynamic>.from(userJson as Map));
  }

  /// POST /auth/logout
  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {
      // Silently fail — user is logging out anyway
    }
    await _client.clearTokens();
  }

  /// POST /auth/forgot-password
  Future<String> forgotPassword(String email) async {
    final response = await _client.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    return response.data['message'] as String? ??
        'If email exists, a reset link has been sent';
  }

  /// PUT /users/profile → { success, user }
  Future<User> updateProfile({String? name, String? phone}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    final response = await _client.put(
      ApiConstants.updateProfile,
      data: body,
    );
    final data = response.data;
    final userJson = data['user'] ?? data['data']?['user'] ?? data;
    return User.fromJson(Map<String, dynamic>.from(userJson as Map));
  }

  /// PUT /auth/password
  Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _client.put(
      ApiConstants.updatePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    return response.data['message'] as String? ?? 'Password updated';
  }
}
