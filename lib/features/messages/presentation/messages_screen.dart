import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/kazi_avatar.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../auth/application/session_controller.dart';
import '../../contact/application/contact_controller.dart';
import '../application/messages_controller.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late final MessagesController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = MessagesController(
      context.read<ContactRepository>(),
      context.read<SessionController>(),
    )..init();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final l = AppLocalizations.of(context);

    return ChangeNotifierProvider.value(
      value: _ctrl,
      child: Scaffold(
        backgroundColor: KaziColors.surfaceAlt,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const OfflineBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KaziSpacing.screenPadding,
                  KaziSpacing.xl,
                  KaziSpacing.screenPadding,
                  KaziSpacing.md,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l.messagesTitle,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: KaziColors.ink,
                    ),
                  ),
                ),
              ),
              if (!session.isAuthenticated)
                Expanded(child: _GuestBody(l: l))
              else
                Expanded(
                  child: Consumer<MessagesController>(
                    builder: (context, ctrl, _) {
                      final state = ctrl.state;

                      if (state is MessagesLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is MessagesError) {
                        final msg = state.error is NetworkException
                            ? l.errorNetwork
                            : l.errorUnknown;
                        return ErrorView(
                          message: msg,
                          onRetry: ctrl.init,
                          retryLabel: l.buttonRetry,
                        );
                      }

                      final contacts =
                          (state as MessagesLoaded).contacts;
                      return _ContactList(contacts: contacts, l: l);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Guest view ────────────────────────────────────────────────────────────────

class _GuestBody extends StatelessWidget {
  const _GuestBody({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KaziSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: KaziColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.messageCircle,
              size: 32,
              color: KaziColors.primary,
            ),
          ),
          const SizedBox(height: KaziSpacing.xl),
          Text(
            l.messagesSignInCta,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              color: KaziColors.body,
            ),
          ),
          const SizedBox(height: KaziSpacing.xl),
          KaziButton(
            label: l.profileSignInButton,
            onPressed: () => context.go(Routes.authPhone),
          ),
        ],
      ),
    );
  }
}

// ── Contact list ──────────────────────────────────────────────────────────────

class _ContactList extends StatelessWidget {
  const _ContactList({required this.contacts, required this.l});

  final List<ContactRecord> contacts;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (contacts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KaziSpacing.screenPadding,
              vertical: KaziSpacing.xxxl,
            ),
            child: Text(
              l.messagesEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                color: KaziColors.muted,
              ),
            ),
          )
        else
          ...contacts.map((c) => _ContactRow(contact: c, l: l)),
        _ChatSoonBanner(l: l),
        const SizedBox(height: KaziSpacing.xxxl),
      ],
    );
  }
}

// ── Contact row ───────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.contact, required this.l});

  final ContactRecord contact;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final channelIcon = contact.channel == 'whatsapp'
        ? LucideIcons.messageCircle
        : LucideIcons.phone;
    final relTime = _relativeTime(contact.lastAt);

    return Container(
      color: KaziColors.surface,
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(
        horizontal: KaziSpacing.screenPadding,
        vertical: KaziSpacing.md,
      ),
      child: Row(
        children: [
          KaziAvatar(
            name: contact.providerName,
            photoUrl: contact.providerPhotoUrl,
          ),
          const SizedBox(width: KaziSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact.providerName,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: KaziColors.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (contact.providerVerified) ...[
                      const SizedBox(width: KaziSpacing.xs),
                      const VerifiedBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(channelIcon, size: 12, color: KaziColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      l.messagesLastContact(relTime),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: KaziColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: KaziSpacing.sm),
          _ReContactButtons(contact: contact, l: l),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// ── Re-contact buttons ────────────────────────────────────────────────────────

class _ReContactButtons extends StatelessWidget {
  const _ReContactButtons({required this.contact, required this.l});

  final ContactRecord contact;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<ContactController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(
          icon: LucideIcons.messageCircle,
          onTap: () => ctrl.contactWhatsApp(
            context: context,
            providerId: contact.providerId,
            providerName: contact.providerName,
            providerPhotoUrl: contact.providerPhotoUrl,
            whatsappNumber: contact.whatsappNumber,
            callNumber: contact.callNumber,
            providerVerified: contact.providerVerified,
          ),
        ),
        if (contact.callNumber != null) ...[
          const SizedBox(width: KaziSpacing.xs),
          _IconBtn(
            icon: LucideIcons.phone,
            onTap: () {
              final phone = contact.callNumber!;
              ctrl.contactCall(
                context: context,
                providerId: contact.providerId,
                providerName: contact.providerName,
                providerPhotoUrl: contact.providerPhotoUrl,
                phoneNumber: phone,
                whatsappNumber: contact.whatsappNumber,
                callNumber: phone,
                providerVerified: contact.providerVerified,
              );
            },
          ),
        ],
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: KaziColors.primarySurface,
          borderRadius: BorderRadius.circular(KaziRadius.button),
        ),
        child: Icon(icon, size: 18, color: KaziColors.primary),
      ),
    );
  }
}

// ── Chat soon banner ──────────────────────────────────────────────────────────

class _ChatSoonBanner extends StatelessWidget {
  const _ChatSoonBanner({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        KaziSpacing.screenPadding,
        KaziSpacing.xl,
        KaziSpacing.screenPadding,
        0,
      ),
      padding: const EdgeInsets.all(KaziSpacing.lg),
      decoration: BoxDecoration(
        color: KaziColors.primarySurface,
        borderRadius: BorderRadius.circular(KaziRadius.card),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.messageSquare, size: 20, color: KaziColors.primary),
          const SizedBox(width: KaziSpacing.md),
          Expanded(
            child: Text(
              l.messagesChatSoon,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: KaziColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
