import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viet_wander/presentation/screens/map_statistics/map_stats_screen.dart';
import 'package:viet_wander/presentation/screens/splash/splash_screen.dart';
import 'package:viet_wander/presentation/screens/welcome/welcome_screen.dart';

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.02, 0), // Slight slide from the right
            end: Offset.zero,
          ).animate(CurveTween(curve: Curves.easeOutQuart).animate(animation)),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    // Bật log để dễ debug trong lúc dev
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/map-stats',
        name: 'mapStats',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const MapStatsScreen(),
        ),
      ),
      // GoRoute(
      //   path: '/road-trip',
      //   name: 'roadTrip',
      //   pageBuilder: (context, state) => buildPageWithDefaultTransition(
      //     context: context,
      //     state: state,
      //     child: const RoadTripScreen(),
      //   ),
      // ),
    ],
  );
});
