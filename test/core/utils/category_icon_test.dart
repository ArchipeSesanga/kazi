import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/category_icon.dart';

void main() {
  test('an unknown iconKey falls back (new categories need no app update)', () {
    expect(categoryIconFor('does_not_exist'), fallbackCategoryIcon);
    expect(categoryIconFor(''), fallbackCategoryIcon);
    expect(categoryIconFor(null), fallbackCategoryIcon);
  });

  test('known keys map to their own icon', () {
    expect(categoryIconFor('plumbing'), Icons.plumbing);
    expect(categoryIconFor('more_horiz'), Icons.more_horiz);
    expect(fallbackCategoryIcon, isNot(Icons.more_horiz));
  });

  test('every iconKey of the bundled taxonomy is known to the app', () {
    final list = jsonDecode(
      File('assets/data/categories.json').readAsStringSync(),
    ) as List<dynamic>;
    for (final c in list.cast<Map<String, dynamic>>()) {
      expect(
        categoryIconKeys.containsKey(c['iconKey']),
        isTrue,
        reason: '${c['id']}: ${c['iconKey']}',
      );
    }
  });
}
