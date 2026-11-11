import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/splash_screen.dart';
import 'routes.dart';

// TODO(KZ-011): replace with full StatefulShellRoute (5 tabs) + all routes
//               from TDD §9.6, including guards from guards.dart.
final appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
  ],
);
