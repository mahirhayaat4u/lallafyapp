import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/shop/shop_screen.dart';
import '../../features/shop/product_detail_screen.dart';
import '../../features/shop/categories_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/orders/order_detail_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/addresses_screen.dart';
import '../../features/profile/change_password_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/referral/referral_screen.dart';
import '../../features/coins/fun_coins_screen.dart';
import '../../features/support/support_screen.dart';
import '../../features/support/terms_screen.dart';
import '../../features/reels/reels_screen.dart';
import '../widgets/bottom_nav_shell.dart';
import '../../providers/auth_provider.dart';

/// App Router — GoRouter configuration with StatefulShellRoute
///
/// 💡 React Native equivalent: This is like your React Navigation setup
/// combining a StackNavigator with a BottomTabNavigator.
///
/// Architecture:
/// - Top-level: Auth routes (no bottom nav) + StatefulShellRoute (with bottom nav)
/// - StatefulShellRoute: 4 branches (Home, Shop, Cart, Profile)
/// - Each branch preserves its own navigation state independently
/// - Overlay routes (product detail, checkout, etc.) push on top of the shell

/// Creates the GoRouter instance with auth-aware redirects
GoRouter createRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,

    // ── Auth-based redirects (like ProtectedRoute) ──
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      // Protected routes — redirect to login if not authenticated
      final protectedRoutes = ['/checkout', '/orders', '/profile', '/wishlist', '/addresses', '/fun-coins'];
      final isProtected = protectedRoutes.any(
          (route) => state.matchedLocation.startsWith(route));
      if (!isLoggedIn && isProtected) return '/login';

      // If user is logged in and tries to visit auth pages → go home
      if (isLoggedIn && isAuthRoute) return '/home';

      // No redirect needed
      return null;
    },

    routes: [
      // ─── Splash Route (NO bottom navigation) ─────────────────
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ─── Auth Routes (NO bottom navigation) ──────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),

      // ─── Main App Shell (WITH bottom navigation) ─────────────
      // StatefulShellRoute preserves each tab's navigation state
      // independently — just like React Navigation's tab navigator.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppBottomNavShell(navigationShell: navigationShell);
        },
        branches: [
          // ── Tab 0: Home ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // ── Tab 1: Shop ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shop',
                name: 'shop',
                builder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  final subCategory = state.uri.queryParameters['subCategory'];
                  final ageGroup = state.uri.queryParameters['ageGroup'];
                  final search = state.uri.queryParameters['search'];
                  final tag = state.uri.queryParameters['tag'];
                  final occasion = state.uri.queryParameters['occasion'];
                  final relation = state.uri.queryParameters['relation'];
                  final sort = state.uri.queryParameters['sort'];
                  final ids = state.uri.queryParameters['ids'];
                  final title = state.uri.queryParameters['title'];
                  final minPriceStr = state.uri.queryParameters['minPrice'];
                  final maxPriceStr = state.uri.queryParameters['maxPrice'];
                  final minPrice = minPriceStr != null ? double.tryParse(minPriceStr) : null;
                  final maxPrice = maxPriceStr != null ? double.tryParse(maxPriceStr) : null;
                  return ShopScreen(
                    initialCategory: category,
                    initialSubCategory: subCategory,
                    initialAgeGroup: ageGroup,
                    initialSearch: search,
                    initialTag: tag,
                    initialOccasion: occasion,
                    initialRelation: relation,
                    initialSort: sort,
                    initialIds: ids,
                    initialTitle: title,
                    initialMinPrice: minPrice,
                    initialMaxPrice: maxPrice,
                  );
                },
              ),
            ],
          ),

          // ── Tab 2: Reels ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reels',
                name: 'reels',
                builder: (context, state) => const ReelsScreen(),
              ),
            ],
          ),

          // ── Tab 3: Categories ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                name: 'categories',
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),

          // ── Tab 4: Profile ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: '/wishlist',
                name: 'wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
        ],
      ),

      // ─── Overlay Routes (push ON TOP of bottom nav) ──────────
      // These routes slide in as full-screen pages over the tab shell.
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/product/:slug',
        name: 'product-detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return ProductDetailScreen(slug: slug);
        },
      ),
      GoRoute(
        path: '/products/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return ProductDetailScreen(slug: slug);
        },
      ),

      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:orderId',
        name: 'order-detail',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/addresses',
        name: 'addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/referral',
        name: 'referral',
        builder: (context, state) => const ReferralScreen(),
      ),
      GoRoute(
        path: '/fun-coins',
        name: 'fun-coins',
        builder: (context, state) => const FunCoinsScreen(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],

    // ─── Error Page ──────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Router provider — depends on auth state
///
/// 💡 When authProvider changes, the router re-evaluates its redirects
final routerProvider = Provider<GoRouter>((ref) {
  return createRouter(ref);
});
