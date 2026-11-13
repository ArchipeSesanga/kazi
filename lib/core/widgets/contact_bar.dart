import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';
import 'kazi_button.dart';

class ContactBar extends StatelessWidget {
  const ContactBar({
    required this.onWhatsApp,
    required this.onCall,
    this.onChat,
    this.whatsAppLabel,
    this.callLabel,
    this.chatLabel,
    super.key,
  });

  final VoidCallback onWhatsApp;
  final VoidCallback onCall;
  final VoidCallback? onChat;
  final String? whatsAppLabel;
  final String? callLabel;
  final String? chatLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaziSpacing.screenPadding,
        vertical: KaziSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: KaziColors.surface,
        border: Border(top: BorderSide(color: KaziColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: KaziButton(
                label: whatsAppLabel ?? 'WhatsApp',
                onPressed: onWhatsApp,
                variant: KaziButtonVariant.whatsapp,
                icon: LucideIcons.messageCircle,
              ),
            ),
            const SizedBox(width: KaziSpacing.sm),
            _IconAction(icon: LucideIcons.phone, onTap: onCall),
            if (onChat != null) ...[
              const SizedBox(width: KaziSpacing.sm),
              _IconAction(icon: LucideIcons.messageSquare, onTap: onChat!),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: KaziColors.primarySurface,
          borderRadius: BorderRadius.circular(KaziRadius.button),
        ),
        child: Icon(icon, size: 20, color: KaziColors.primary),
      ),
    );
  }
}
