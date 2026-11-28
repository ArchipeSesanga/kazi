import 'package:flutter/material.dart';

/// Material icon of each `iconKey` stored on `categories/{slug}`.
const Map<String, IconData> categoryIconKeys = {
  'plumbing': Icons.plumbing,
  'electrical_services': Icons.electrical_services,
  'construction': Icons.construction,
  'format_paint': Icons.format_paint,
  'carpenter': Icons.carpenter,
  'hardware': Icons.hardware,
  'ac_unit': Icons.ac_unit,
  'cleaning_services': Icons.cleaning_services,
  'yard': Icons.yard,
  'content_cut': Icons.content_cut,
  'face_retouching_natural': Icons.face_retouching_natural,
  'checkroom': Icons.checkroom,
  'phone_android': Icons.phone_android,
  'computer': Icons.computer,
  'home_repair_service': Icons.home_repair_service,
  'car_repair': Icons.car_repair,
  'local_shipping': Icons.local_shipping,
  'delivery_dining': Icons.delivery_dining,
  'school': Icons.school,
  'celebration': Icons.celebration,
  'photo_camera': Icons.photo_camera,
  'security': Icons.security,
  'more_horiz': Icons.more_horiz,
};

/// Shown for an `iconKey` this app version does not know: categories can be
/// added server-side without an app update.
const IconData fallbackCategoryIcon = Icons.category_outlined;

IconData categoryIconFor(String? iconKey) =>
    categoryIconKeys[iconKey] ?? fallbackCategoryIcon;
