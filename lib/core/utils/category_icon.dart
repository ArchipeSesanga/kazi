import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

IconData categoryIconForName(String name) => switch (name) {
      'wrench' => LucideIcons.wrench,
      'zap' => LucideIcons.zap,
      'scissors' => LucideIcons.scissors,
      'shirt' => LucideIcons.shirt,
      'hammer' => LucideIcons.hammer,
      'brick-wall' => LucideIcons.brickWall,
      'paint-roller' => LucideIcons.paintRoller,
      'car' => LucideIcons.car,
      'smartphone' => LucideIcons.smartphone,
      'laptop' => LucideIcons.laptop,
      'graduation-cap' => LucideIcons.graduationCap,
      'sparkles' => LucideIcons.sparkles,
      'chef-hat' => LucideIcons.chefHat,
      'truck' => LucideIcons.truck,
      'party-popper' => LucideIcons.partyPopper,
      'snowflake' => LucideIcons.snowflake,
      'flame' => LucideIcons.flame,
      'sprout' => LucideIcons.sprout,
      'baby' => LucideIcons.baby,
      _ => LucideIcons.moreHorizontal,
    };
