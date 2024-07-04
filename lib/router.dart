import 'package:Teriya/pages/onboarding.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'package:flutter/cupertino.dart';

import 'pages/loading_splash.dart';
import 'pages/home.dart';
import 'pages/welcome.dart';
import 'package:go_router/go_router.dart';

class FadeTransitionRoute extends GoRoute {
  FadeTransitionRoute({
    required super.path,
    required Widget page,
    super.name,
    List<GoRoute>? routes,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, state) =>
              _fadePageBuilder(page, state, transitionDuration),
          routes: routes ?? [],
        );

  static Page<dynamic> _fadePageBuilder(
      Widget child, GoRouterState state, Duration duration) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: duration,
    );
  }
}

class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    routes: [
      FadeTransitionRoute(
          path: '/splash', name: 'splash', page: const LoadingSplashScreen()),
      FadeTransitionRoute(
          path: '/welcome', name: 'welcome', page: const TeriyaWelcomeScreen()),
      FadeTransitionRoute(path: '/home', name: 'home', page: const HomePage()),
      FadeTransitionRoute(
          path: '/onboarding',
          name: 'onboarding',
          page: const MeetAllyOnboarding())
    ],
    initialLocation: '/splash',
    redirect: (context, state) {
      final authService = Provider.of<AuthService>(context, listen: false);
      // Global redirect logic to handle authentication
      final loggedIn = authService.user != null;
      final goingToWelcome = state.fullPath == '/welcome';
      print("state fullpath ${state.fullPath}");
      // Always redirect to splash at the beginning to handle auth check
      if (!loggedIn && !goingToWelcome && state.fullPath != '/splash') {
        print("redirecting to splash");
        return '/splash';
      }

      // Redirect to home if logged in and trying to go to welcome
      if (loggedIn && goingToWelcome) {
        print("redirecting to home");
        // return '/home';
        return '/onboarding';
      }

      return state.fullPath;
    },
  );
}
