import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/widgets/kazi_logo.dart';
import '../../auth/application/session_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listenSession());
  }

  void _listenSession() {
    final session = context.read<SessionController>();
    if (!session.isLoading) {
      _navigate(session);
      return;
    }
    session.addListener(() {
      if (mounted && !session.isLoading) _navigate(session);
    });
  }

  void _navigate(SessionController session) {
    if (!mounted) return;
    if (session.isAuthenticated) {
      context.go(Routes.home);
    } else {
      context.go(Routes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mirrors the native launch screen (same background and image) so the
    // hand-off from native splash to Flutter is seamless: one splash only.
    return const Scaffold(
      backgroundColor: KaziColors.ink,
      body: Center(
        child: KaziLogo(variant: KaziLogoVariant.symbolReversed, width: 112),
      ),
    );
  }
}
