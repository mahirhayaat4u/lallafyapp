/// API endpoint constants
///
/// 💡 React Native equivalent: These are like your baseURL and endpoint strings
/// from the api/ folder, but organized as constants.
class ApiConstants {
  ApiConstants._();
  

  /// Base URL — update this to your backend's deployed URL
  /// In development, use your local machine's IP (not localhost!)
  /// because the Android emulator can't reach localhost on the host machine.
  ///
  /// For Android emulator → use 10.0.2.2 (maps to host's localhost)
  /// For physical device → use your computer's local IP (e.g., 192.168.1.100)
  // static const String baseUrl = 'http://10.0.2.2:5000/api/v1';//virtual api
  // static const String baseUrl = 'http://192.168.1.68:5000/api/v1'; // Physical device
  static const String baseUrl = 'https://api.giftswale.com/api/v1';//main api

  // ─── Auth ────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String registerVendor = '/auth/register/vendor';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String updateProfile = '/auth/profile';
  static const String updatePassword = '/auth/password';

  // ─── Products ────────────────────────────────────────────
  static const String products = '/products';
  static const String featuredProducts = '/products/featured';
  static String productBySlug(String slug) => '/products/$slug';
  static String productReviews(String productId) =>
      '/products/$productId/reviews';

  // ─── Categories ──────────────────────────────────────────
  static const String categories = '/categories';

  // ─── Cart ────────────────────────────────────────────────
  static const String cartSync = '/cart/sync';

  // ─── Wishlist ────────────────────────────────────────────
  static const String wishlist = '/wishlist';
  static String wishlistItem(String productId) => '/wishlist/$productId';

  // ─── Addresses ───────────────────────────────────────────
  static const String addresses = '/addresses';
  static String address(String id) => '/addresses/$id';
  static String addressDefault(String id) => '/addresses/$id/default';

  // ─── Orders ──────────────────────────────────────────────
  static const String orders = '/orders';
  static const String ordersCod = '/orders/cod';
  static String orderDetail(String orderNumber) => '/orders/$orderNumber';
  static String orderCancel(String orderId) => '/orders/$orderId/cancel';
  static String orderReturn(String orderId) => '/orders/$orderId/return';
  static const String myReturns = '/orders/returns';

  // ─── Payments ────────────────────────────────────────────
  static const String paymentsCreate = '/payments/create';
  static const String paymentsVerify = '/payments/verify';
  static String paymentStatus(String cfOrderId) =>
      '/payments/status/$cfOrderId';

  // ─── Coupons ─────────────────────────────────────────────
  static const String couponApply = '/coupons/apply';

  // ─── Reviews ─────────────────────────────────────────────
  static String deleteReview(String reviewId) => '/reviews/$reviewId';

  // ─── Contact ─────────────────────────────────────────────
  static const String contact = '/contact';

  // ─── Store (Public) ──────────────────────────────────────
  static String storeBySlug(String slug) => '/stores/$slug';

  // ─── Banners ─────────────────────────────────────────────
  static const String banners = '/banners';

  // ─── Menus ───────────────────────────────────────────────
  static const String menus = '/menus';

  // ─── Homepage Sections ───────────────────────────────────
  static const String flowerCards = '/homepage-flower-cards';
  static const String relationshipCards = '/homepage-relationship-cards';
  static const String occasionTabs = '/homepage-occasion-tabs';
  static const String giftingStories = '/homepage-gifting-stories';
  static const String luxuryCards = '/homepage-luxury-cards';
  static const String personalizeCards = '/homepage-personalize-cards';
  static const String comboCards = '/homepage-combo-cards';

  // ─── App Version (Update Check) ──────────────────────────
  static const String appVersion = '/app/version';
}
