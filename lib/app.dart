import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/update_checker.dart';

/// Root App Widget
///
/// 💡 React Native equivalent: Your top-level App component that wraps
/// everything with providers (QueryClientProvider, Router, etc.)
///
/// In Flutter, MaterialApp.router acts as the root widget that:
/// - Applies the theme (like your CSS design system)
/// - Sets up the router (like BrowserRouter)
/// - Configures global behaviors
///
/// ConsumerWidget is Riverpod's version of a widget that can read providers.
class GiftsWaleApp extends ConsumerWidget {
  const GiftsWaleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'GiftsWale',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return _UpdateCheckWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// Runs the update check exactly once when the app starts.
class _UpdateCheckWrapper extends StatefulWidget {
  final Widget child;
  const _UpdateCheckWrapper({required this.child});

  @override
  State<_UpdateCheckWrapper> createState() => _UpdateCheckWrapperState();
}

class _UpdateCheckWrapperState extends State<_UpdateCheckWrapper> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    // Delay so the home screen renders first
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_checked) {
        _checked = true;
        UpdateChecker.check(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}


