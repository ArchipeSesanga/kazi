import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/domain/auth_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: KaziColors.surfaceAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: session.isAuthenticated || session.isProfileIncomplete
                  ? _AuthenticatedBody(user: session.appUser, l: l)
                  : _GuestBody(l: l),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthenticatedBody extends StatelessWidget {
  const _AuthenticatedBody({required this.user, required this.l});

  final dynamic user;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName as String? ?? '';
    final phone = user?.phone as String? ?? '';
    final initials = _initials(displayName);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Header(displayName: displayName, phone: phone, initials: initials),
        const SizedBox(height: KaziSpacing.sm),
        _SectionCard(
          children: [
            _Tile(
              icon: Icons.storefront_outlined,
              label: l.profileProviderSpace,
              onTap: () => context.push(Routes.providerOnboarding),
            ),
          ],
        ),
        const SizedBox(height: KaziSpacing.sm),
        _SectionCard(
          children: [
            _Tile(
              icon: Icons.favorite_outline_rounded,
              label: l.profileFavorites,
              onTap: () => context.push(Routes.myFavorites),
            ),
            const _Divider(),
            _Tile(
              icon: Icons.language_rounded,
              label: l.profileLanguage,
              onTap: () => context.push(Routes.myLanguage),
            ),
            const _Divider(),
            _Tile(
              icon: Icons.help_outline_rounded,
              label: l.profileHelp,
              onTap: () => context.push(Routes.help),
            ),
          ],
        ),
        const SizedBox(height: KaziSpacing.sm),
        _SectionCard(
          children: [
            _Tile(
              icon: Icons.description_outlined,
              label: l.profileTerms,
              onTap: () => context.push(Routes.legalTerms),
            ),
            const _Divider(),
            _Tile(
              icon: Icons.shield_outlined,
              label: l.profilePrivacy,
              onTap: () => context.push(Routes.legalPrivacy),
            ),
          ],
        ),
        const SizedBox(height: KaziSpacing.sm),
        _SectionCard(
          children: [
            _Tile(
              icon: Icons.logout_rounded,
              label: l.profileSignOut,
              color: KaziColors.error,
              onTap: () => _signOut(context),
            ),
          ],
        ),
        const SizedBox(height: KaziSpacing.sm),
        _SectionCard(
          children: [
            _Tile(
              icon: Icons.delete_outline_rounded,
              label: l.profileDeleteAccount,
              color: KaziColors.error,
              onTap: () => context.push(Routes.deleteAccount),
            ),
          ],
        ),
        const SizedBox(height: KaziSpacing.xxxl),
      ],
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _SignOutDialog(l: l),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthRepository>().signOut();
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.displayName,
    required this.phone,
    required this.initials,
  });

  final String displayName;
  final String phone;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      color: KaziColors.surface,
      padding: const EdgeInsets.fromLTRB(
        KaziSpacing.screenPadding,
        KaziSpacing.xl,
        KaziSpacing.screenPadding,
        KaziSpacing.xl,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              gradient: KaziColors.brandGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: KaziSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isEmpty ? '—' : displayName,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: KaziColors.ink,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: KaziColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: KaziColors.primary),
            tooltip: l.profileEditName,
            onPressed: () => context.push(Routes.mySettings),
          ),
        ],
      ),
    );
  }
}

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
              Icons.person_outline_rounded,
              size: 36,
              color: KaziColors.primary,
            ),
          ),
          const SizedBox(height: KaziSpacing.xl),
          Text(
            l.profileSignInCta,
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
            onPressed: () => context.go(Routes.authEmail),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KaziColors.surface,
      child: Column(children: children),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? KaziColors.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KaziSpacing.screenPadding,
          vertical: KaziSpacing.lg,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: tileColor),
            const SizedBox(width: KaziSpacing.lg),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: tileColor,
                ),
              ),
            ),
            if (color == null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: KaziColors.muted,
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: KaziSpacing.screenPadding + 22 + KaziSpacing.lg),
      child: Divider(height: 1, thickness: 1, color: KaziColors.border),
    );
  }
}

class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        l.profileSignOut,
        style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
      ),
      content: Text(
        l.profileSignOutConfirmBody,
        style: const TextStyle(fontFamily: 'Montserrat'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            l.buttonCancel,
            style: const TextStyle(fontFamily: 'Montserrat', color: KaziColors.muted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            l.buttonSignOut,
            style: const TextStyle(fontFamily: 'Montserrat', color: KaziColors.error),
          ),
        ),
      ],
    );
  }
}
