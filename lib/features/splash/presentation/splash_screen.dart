import 'package:flutter/material.dart';

// S01 — placeholder; KZ-006 will replace hardcoded colour with KaziColors.primary
// and KZ-011 will add the router guard that navigates onward after bootstrap.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF5C3E94), // TODO(KZ-006): KaziColors.primary
      body: Center(
        child: Text(
          'Kazi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
