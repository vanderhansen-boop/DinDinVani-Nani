// lib/presentation/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_notifier.dart';
import '../features/auth/providers/auth_state.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../shared/layouts/main_layout.dart';

class _AuthRouterListener extends ChangeNotifier {
  _AuthRouterListener(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listener = _AuthRouterListener(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listener,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/splash',  builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',   builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup',  builder: (_, __) => const SignUpScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const MainLayout(initialIndex: 0),
      ),
      GoRoute(
        path: '/transactions',
        builder: (_, __) => const MainLayout(initialIndex: 1),
      ),
      GoRoute(
        path: '/piggy-banks',
        builder: (_, __) => const MainLayout(initialIndex: 2),
      ),
      GoRoute(
        path: '/planning',
        builder: (_, __) => const MainLayout(initialIndex: 3),
      ),
      GoRoute(
        path: '/credit-cards',
        builder: (_, __) => const MainLayout(initialIndex: 4),
      ),
      GoRoute(
        path: '/reports',
        builder: (_, __) => const MainLayout(initialIndex: 5),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const MainLayout(initialIndex: 6),
      ),
    ],
    redirect: (context, gstate) {
      final auth = ref.read(authNotifierProvider);
      final loc  = gstate.matchedLocation;
      final isAuth   = loc == '/login' || loc == '/signup';
      final isSplash = loc == '/splash';

      if (auth is AuthInitial || auth is AuthLoading) {
        return isSplash ? null : '/splash';
      }
      if (auth is AuthAuthenticated) {
        if (isAuth || isSplash) return '/dashboard';
        return null;
      }
      if (isAuth) return null;
      return '/login';
    },
  );
});