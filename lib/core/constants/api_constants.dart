/// API endpoint constants
///
/// 💡 React Native equivalent: These are like your baseURL and endpoint strings
/// from the api/ folder, but organized as constants.
class ApiConstants {
  ApiConstants._();

  /// Base URL — points to lallafy.com backend
  /// For Android emulator → use http://10.0.2.2:5000/api
  /// For physical device / production → update accordingly
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  // static const String baseUrl ='http://10.206.218.188/api';
  // static const String baseUrl = 'https://api.lallafy.com/api';

  // ─── Auth ────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String googleLogin = '/auth/google';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // ─── User Profile ────────────────────────────────────────
  static const String updateProfile = '/users/profile';
  static const String updatePassword = '/users/change-password';
  static const String uploadAvatar = '/users/avatar';
  static const String deleteAccount = '/users/delete';

  // ─── Products ────────────────────────────────────────────
  static const String products = '/products';
  static String productById(String id) => '/products/$id';

  // ─── Categories & Content ───────────────────────────────
  static const String categories = '/categories';
  static const String ageGroups = '/age-groups';
  static const String carousel = '/carousel';
  static const String sectionBanners = '/section-banners';
  static const String videoProducts = '/video-products';

  // ─── Cart ────────────────────────────────────────────────
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';

  // ─── Wishlist ────────────────────────────────────────────
  static const String wishlist = '/wishlist';
  static String wishlistItem(String productId) => '/wishlist/$productId';

  // ─── Addresses ───────────────────────────────────────────
  static const String addresses = '/addresses';
  static String address(String id) => '/addresses/$id';
  static String addressDefault(String id) => '/addresses/$id/default';

  // ─── Orders ──────────────────────────────────────────────
  static const String orders = '/orders';
  static const String myOrders = '/orders/my';
  static String orderDetail(String id) => '/orders/my/$id';

  // ─── Payments ────────────────────────────────────────────
  static const String paymentsCreate = '/payment/create-order';
  static const String paymentsVerify = '/payment/verify-payment';

  // ─── Reviews ─────────────────────────────────────────────
  static const String reviews = '/reviews';
  static String productReviews(String productId) => '/reviews/product/$productId';
  static String canReview(String productId) => '/reviews/can-review/$productId';
  static String deleteReview(String id) => '/reviews/$id';
  static const String homepageReviews = '/reviews/homepage';

  // ─── Contact ─────────────────────────────────────────────
  static const String contact = '/contacts';

  // ─── Aliases for compatibility & fallbacks ─────────────
  static const String refresh = '/auth/refresh';
  static String productBySlug(String slug) => '/products/$slug';
  static const String appVersion = '/app/version';
  static const String couponApply = '/coupons/apply';
  static const String ordersCod = '/orders/cod';
  static const String cartSync = '/cart/sync';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static const String banners = '/carousel';
  static const String featuredProducts = '/products?featured=true';
  static const String flowerCards = '/homepage-flower-cards';
  static const String relationshipCards = '/homepage-relationship-cards';
  static const String luxuryCards = '/homepage-luxury-cards';
  static const String personalizeCards = '/homepage-personalize-cards';
  static const String comboCards = '/homepage-combo-cards';
  static const String occasionTabs = '/homepage-occasion-tabs';
  static const String giftingStories = '/homepage-gifting-stories';
}
