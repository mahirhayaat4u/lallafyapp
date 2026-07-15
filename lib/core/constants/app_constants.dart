/// App-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'GiftsWale';
  static const String appTagline = 'Gift Your Loved Ones';
  static const String appVersion = '1.0.0';
  static const String currencySymbol = '₹';

  // ─── Storage Keys ────────────────────────────────────────
  static const String accessTokenKey = 'gw_access_token';
  static const String refreshTokenKey = 'gw_refresh_token';
  static const String userKey = 'gw_user';
  static const String cartKey = 'gw_cart';
  static const String onboardingKey = 'gw_onboarding_done';

  // ─── Pagination ──────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ─── Debounce ────────────────────────────────────────────
  static const Duration searchDebounce = Duration(milliseconds: 400);

  // ─── Image Placeholders ──────────────────────────────────
  static const String productPlaceholder = 'assets/images/placeholder_product.png';
  static const String avatarPlaceholder = 'assets/images/placeholder_avatar.png';
}
