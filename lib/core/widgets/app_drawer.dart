import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isLoggedIn = authState.isAuthenticated;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Header Section ──
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            currentAccountPicture: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: user?.avatar != null && user!.avatar!.isNotEmpty
                    ? Image.network(
                        user.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultAvatar(),
                      )
                    : _defaultAvatar(),
              ),
            ),
            accountName: Text(
              isLoggedIn ? (user?.name ?? 'Lallafy Customer') : 'Welcome to Lallafy',
              style: AppTextStyles.bodySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            accountEmail: Text(
              isLoggedIn ? (user?.email ?? '') : 'Shop premium toys & kids products ✨',
              style: AppTextStyles.bodyXs.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),

          // ── Navigation Options ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerTile(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  onTap: () {
                    context.pop(); // Close drawer
                    context.go('/home');
                  },
                ),
                _drawerTile(
                  icon: Icons.toys_outlined,
                  label: 'Explore Toys',
                  onTap: () {
                    context.pop();
                    context.go('/categories');
                  },
                ),
                _drawerTile(
                  icon: Icons.grid_view_outlined,
                  label: 'Categories',
                  onTap: () {
                    context.pop();
                    context.go('/categories'); // Go to categories
                  },
                ),
                const Divider(),
                _drawerTile(
                  icon: Icons.shopping_bag_outlined,
                  label: 'My Orders',
                  onTap: () {
                    context.pop();
                    context.push('/orders');
                  },
                ),
                _drawerTile(
                  icon: Icons.favorite_border_rounded,
                  label: 'My Wishlist',
                  onTap: () {
                    context.pop();
                    context.push('/wishlist');
                  },
                ),
                _drawerTile(
                  icon: Icons.person_outline_rounded,
                  label: 'My Profile',
                  onTap: () {
                    context.pop();
                    context.go('/profile');
                  },
                ),
                _drawerTile(
                  icon: Icons.pin_drop_outlined,
                  label: 'Saved Addresses',
                  onTap: () {
                    context.pop();
                    context.push('/addresses');
                  },
                ),
                const Divider(),
                _drawerTile(
                  icon: Icons.support_agent_rounded,
                  label: 'Contact Support & FAQ',
                  onTap: () {
                    context.pop();
                    context.push('/support');
                  },
                ),
              ],
            ),
          ),

          // ── Bottom Logout / Login Section ──
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoggedIn
                  ? OutlinedButton.icon(
                      onPressed: () {
                        context.pop();
                        ref.read(authProvider.notifier).logout();
                        context.go('/home');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Logout Account'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        context.pop();
                        context.push('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('Login / Sign Up'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.grey.shade100,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.text.withValues(alpha: 0.7), size: 22),
      title: Text(
        label,
        style: AppTextStyles.bodySm.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      onTap: onTap,
    );
  }
}
