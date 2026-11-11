import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO(KZ-002): populate with Firebase singletons, repositories and
//               global controllers per TDD §9.5.
class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: const [],
      child: child,
    );
  }
}
