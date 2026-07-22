import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/network/api_exceptions.dart';
import '../core/network/dio_client.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

/// Auth state — immutable snapshot of authentication state
///
/// 💡 React Native equivalent: This is like the state shape of your
/// Zustand useAuthStore: { user, isLoading }
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isVendor => user?.isVendor ?? false;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Auth Provider — Riverpod StateNotifier for authentication
///
/// 💡 React Native equivalent: This is like your Zustand `useAuthStore`
/// with `login`, `register`, `logout`, `fetchMe` actions.
///
/// StateNotifier is Riverpod's way of managing mutable state with actions.
/// It's very similar to Zustand's create() pattern:
///
///   Zustand:     const { login, logout, user } = useAuthStore()
///   Riverpod:    final authState = ref.watch(authProvider)
///                ref.read(authProvider.notifier).login(...)
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final DioClient _client = DioClient();

  AuthNotifier(this._repo) : super(const AuthState()) {
    // Try to restore user from local storage on app start
    _tryRestoreUser();
  }

  /// Attempt to restore saved user session
  Future<void> _tryRestoreUser() async {
    try {
      final hasTokens = await _client.hasTokens();
      if (!hasTokens) return;

      // Load cached user from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.userKey);
      if (userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        state = state.copyWith(user: user);
      }

      // Verify with server in background (silent — don't show loading)
      try {
        final freshUser = await _repo.fetchMe();
        state = state.copyWith(user: freshUser);
        await _saveUserLocally(freshUser);
      } catch (_) {
        // Token might be expired — the Dio interceptor will handle refresh
        // If refresh also fails, user will be logged out
      }
    } catch (_) {
      // No stored session — user needs to log in
    }
  }

  /// Login with email and password
  ///
  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.login(email: email, password: password);

      // Save token
      await _client.saveTokens(
        accessToken: result.token,
        refreshToken: result.token,
      );

      // Save user locally
      await _saveUserLocally(result.user);

      state = state.copyWith(user: result.user, isLoading: false);

      // Fetch full user profile from server in background (phone, addresses, etc.)
      try {
        final freshUser = await _repo.fetchMe();
        state = state.copyWith(user: freshUser);
        await _saveUserLocally(freshUser);
      } catch (_) {}
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } on DioException catch (e) {
      final msg = (e.error is ApiException)
          ? (e.error as ApiException).message
          : ((e.response?.data is Map)
              ? (e.response?.data['message'] ?? e.response?.data['error'] ?? 'Login failed. Please check credentials.')
              : 'Login failed. Please check credentials.');
      state = state.copyWith(isLoading: false, error: msg);
      throw ApiException(message: msg, statusCode: e.response?.statusCode);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please try again.',
      );
      throw ApiException(message: 'Login failed. Please try again.');
    }
  }

  /// Register a new customer account
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.register(
        name: name,
        email: email,
        password: password,
      );

      await _client.saveTokens(
        accessToken: result.token,
        refreshToken: result.token,
      );
      await _saveUserLocally(result.user);

      state = state.copyWith(user: result.user, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } on DioException catch (e) {
      final msg = (e.error is ApiException)
          ? (e.error as ApiException).message
          : ((e.response?.data is Map)
              ? (e.response?.data['message'] ?? e.response?.data['error'] ?? 'User already exists or registration failed.')
              : 'Registration failed. Check details.');
      state = state.copyWith(isLoading: false, error: msg);
      throw ApiException(message: msg, statusCode: e.response?.statusCode);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed. Please try again.',
      );
      throw ApiException(message: 'Registration failed. Please try again.');
    }
  }

  /// Logout — clear all tokens and user data
  ///
  /// 💡 Mirrors: useAuthStore().logout()
  Future<void> logout() async {
    await _repo.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
    state = const AuthState(); // Reset to initial state
  }

  /// Fetch latest user profile from server
  ///
  /// 💡 Mirrors: useAuthStore().fetchMe()
  Future<void> fetchMe() async {
    try {
      final user = await _repo.fetchMe();
      state = state.copyWith(user: user);
      await _saveUserLocally(user);
    } catch (_) {
      state = state.copyWith(clearUser: true);
    }
  }

  /// Update user profile
  Future<void> updateProfile({String? name, String? phone}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.updateProfile(name: name, phone: phone);
      state = state.copyWith(user: user, isLoading: false);
      await _saveUserLocally(user);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Save user JSON to SharedPreferences for offline access
  Future<void> _saveUserLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }
}

// ─── Riverpod Providers ──────────────────────────────────────────

/// Repository provider (singleton)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Auth state provider — use this throughout the app
///
/// Usage:
///   final authState = ref.watch(authProvider);        // read state
///   ref.read(authProvider.notifier).login(...)         // call actions
///
/// 💡 Zustand equivalent:
///   const { user, isLoading } = useAuthStore()         → ref.watch(authProvider)
///   const { login, logout } = useAuthStore()           → ref.read(authProvider.notifier)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthNotifier(repo);
});
