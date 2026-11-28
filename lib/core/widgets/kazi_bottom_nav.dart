import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

/// Custom bottom navigation bar with a raised accent "Publier" button in the centre.
class KaziBottomNav extends StatelessWidget {
  const KaziBottomNav({
    required this.currentIndex,
    required this.onTap,
    this.homeLabel = 'Accueil',
    this.exploreLabel = 'Explorer',
    this.publishLabel = 'Publier',
    this.messagesLabel = 'Messages',
    this.meLabel = 'Moi',
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String homeLabel;
  final String exploreLabel;
  final String publishLabel;
  final String messagesLabel;
  final String meLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KaziColors.surface,
        border: Border(top: BorderSide(color: KaziColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: LucideIcons.home,
                label: homeLabel,
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: LucideIcons.compass,
                label: exploreLabel,
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _PublishButton(
                label: publishLabel,
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: LucideIcons.messageCircle,
                label: messagesLabel,
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: LucideIcons.user,
                label: meLabel,
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? KaziColors.primary : KaziColors.muted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishButton extends StatelessWidget {
  const _PublishButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: KaziColors.brandGradient,
                borderRadius: BorderRadius.circular(KaziRadius.button),
                boxShadow: KaziColors.accentButtonShadow,
              ),
              child: const Icon(LucideIcons.plus, size: 24, color: Colors.white),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: KaziColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
