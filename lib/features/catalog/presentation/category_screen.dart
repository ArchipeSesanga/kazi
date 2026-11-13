import 'package:flutter/material.dart';

import '../../../app/widgets/placeholder_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(name: 'Catégorie');
}
