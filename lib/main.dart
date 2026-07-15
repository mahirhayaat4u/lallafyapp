import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

/// Application Entry Point
///
/// 💡 React Native equivalent: Your index.js / App.tsx entry point.
///
/// Key concepts:
/// - `WidgetsFlutterBinding.ensureInitialized()` — needed before any async work
/// - `ProviderScope` — Riverpod's equivalent of React Context providers
///    (like wrapping your app in `<QueryClientProvider>`)
/// - `SystemChrome` — controls status bar appearance (no RN equivalent needed)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for now
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    // ProviderScope is Riverpod's root — must wrap the entire app.
    // Think of it as <QueryClientProvider> + <AuthProvider> + all your
    // React Context providers combined into one.
    const ProviderScope(
      child: GiftsWaleApp(),
    ),
  );
}


