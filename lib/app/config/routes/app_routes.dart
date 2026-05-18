import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viet_wander/presentation/screens/map_statistics/map_stats_screen.dart';
import 'package:viet_wander/presentation/screens/welcome/welcome_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Bật log để dễ debug trong lúc dev
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/map-stats',
        name: 'mapStats',
        builder: (context, state) => const MapStatsScreen(),
      ),
      // GoRoute(
      //   path: '/road-trip',
      //   name: 'roadTrip',
      //   builder: (context, state) => const RoadTripScreen(),
      // ),
    ],
  );
});
