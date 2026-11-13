import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';

class KaziNetworkImage extends StatelessWidget {
  const KaziNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    super.key,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: KaziColors.surfaceAlt,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(LucideIcons.image, size: 24, color: KaziColors.border),
      ),
    );

    if (url == null || url!.isEmpty) return placeholder;

    Widget image = CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
      fadeInDuration: const Duration(milliseconds: 200),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
