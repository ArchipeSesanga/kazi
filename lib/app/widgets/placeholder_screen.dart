import 'package:flutter/material.dart';

/// Temporary scaffold used by placeholder screens.
/// Replace each screen's body with real UI; delete this file when done.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Text(
          '$name\n(placeholder)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
