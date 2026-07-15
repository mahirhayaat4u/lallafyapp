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

  /// POST /auth/login → { user, tokens }
  Future<({User user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data['data'];
    return (
      user: User.fromJson(data['user']),
      accessToken: data['tokens']['accessToken'] as String,
      refreshToken: data['tokens']['refreshToken'] as String,
    );
  }

  /// POST /auth/register → { user, tokens }
  Future<({User user, String accessToken, String refreshToken})> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await _client.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': 'customer',
      },
    );
    final data = response.data['data'];
    return (
      user: User.fromJson(data['user']),
      accessToken: data['tokens']['accessToken'] as String,
      refreshToken: data['tokens']['refreshToken'] as String,
    );
  }

  /// GET /auth/me → { user }
  Future<User> fetchMe() async {
    final response = await _client.get(ApiConstants.me);
    return User.fromJson(response.data['data']['user']);
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

  /// PUT /auth/profile → { user }
  Future<User> updateProfile({String? name, String? phone}) async {
    final response = await _client.put(
      ApiConstants.updateProfile,
      data: {
        'name': ?name,
        'phone': ?phone,
      },
    );
    return User.fromJson(response.data['data']['user']);
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
