import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/enums.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/application/session_controller.dart';
import '../../provider_profile/domain/provider_repository.dart';
import '../application/publish_hub_controller.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  late final PublishHubController _ctrl;
  ProviderStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    _ctrl = PublishHubController(context.read<ProviderRepository>());
    final uid = context.read<SessionController>().uid;
    if (uid != null) _ctrl.init(uid);
  }

  void _onProfileChanged(ProviderProfile? profile) {
    final status = profile?.status;
    // Auto-approval (v1) resolves almost instantly — jump straight to the
    // dashboard the moment we see pending flip to approved, instead of
    // making the user tap through the hub again.
    if (_lastStatus == ProviderStatus.pending &&
        status == ProviderStatus.approved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only when this hub is the visible screen: if onboarding just
        // finished it already opened the dashboard on top of us.
        if (!mounted) return;
        final location = GoRouter.of(context)
            .routerDelegate
            .currentConfiguration
            .uri
            .path;
        if (location == Routes.publish) context.push(Routes.providerDashboard);
      });
    }
    _lastStatus = status;
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

    return Scaffold(
      backgroundColor: KaziColors.surfaceAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KaziSpacing.screenPadding,
                KaziSpacing.lg,
                KaziSpacing.screenPadding,
                KaziSpacing.md,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.publishHubTitle,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: KaziColors.ink,
                  ),
                ),
              ),
            ),
            Expanded(
              child: session.uid == null
                  ? _GuestView(l: l)
                  : ChangeNotifierProvider.value(
                      value: _ctrl,
                      child: Consumer<PublishHubController>(
                        builder: (ctx, ctrl, _) {
                          if (ctrl.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          }
                          if (ctrl.hasError) {
                            return _ErrorView(l: l);
                          }
                          final profile = ctrl.profile;
                          _onProfileChanged(profile);
                          if (profile == null) {
                            return _NonProviderView(l: l);
                          }
                          return switch (profile.status) {
                            ProviderStatus.pending => _PendingView(l: l),
                            ProviderStatus.approved => _ApprovedView(l: l),
                            ProviderStatus.rejected => _RejectedView(
                                reason: profile.statusReason,
                                l: l,
                              ),
                            ProviderStatus.suspended => _SuspendedView(l: l),
                          };
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guest ─────────────────────────────────────────────────────────────────────

class _GuestView extends StatelessWidget {
  const _GuestView({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return _HubCard(
      icon: LucideIcons.briefcase,
      message: l.publishHubGuestCta,
      child: KaziButton(
        label: l.profileSignInButton,
        onPressed: () => context.go(Routes.authEmail),
      ),
    );
  }
}

// ── Non-provider ──────────────────────────────────────────────────────────────

class _NonProviderView extends StatelessWidget {
  const _NonProviderView({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return _HubCard(
      icon: LucideIcons.store,
      title: l.publishHubBecomeProvider,
      message: l.publishHubBecomeProviderSubtitle,
      child: KaziButton(
        label: l.publishHubBecomeProvider,
        onPressed: () => context.push(Routes.providerOnboarding),
      ),
    );
  }
}

// ── Pending ───────────────────────────────────────────────────────────────────

class _PendingView extends StatelessWidget {
  const _PendingView({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return _HubCard(
      icon: LucideIcons.clock,
      message: l.publishHubPending,
    );
  }
}

// ── Approved ──────────────────────────────────────────────────────────────────

class _ApprovedView extends StatelessWidget {
  const _ApprovedView({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return _HubCard(
      icon: LucideIcons.circleCheck,
      iconColor: KaziColors.success,
      message: l.publishHubApproved,
      child: KaziButton(
        label: l.publishHubGoToDashboard,
        onPressed: () => context.push(Routes.providerDashboard),
      ),
    );
  }
}

// ── Rejected ──────────────────────────────────────────────────────────────────

class _RejectedView extends StatelessWidget {
  const _RejectedView({required this.l, this.reason});
  final AppLocalizations l;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    return _HubCard(
      icon: LucideIcons.circleX,
      iconColor: KaziColors.error,
      title: l.publishHubRejected,
      message: reason,
      child: KaziButton(
        label: l.publishHubResubmit,
        onPressed: () => context.push(Routes.providerOnboarding),
      ),
    );
  }
}

// ── Suspended ─────────────────────────────────────────────────────────────────

class _SuspendedView extends StatelessWidget {
  const _SuspendedView({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return _HubCard(
      icon: LucideIcons.ban,
      iconColor: KaziColors.error,
      message: l.publishHubSuspended,
      child: KaziButton(
        label: l.publishHubSupportCta,
        variant: KaziButtonVariant.outline,
        onPressed: () => context.push(Routes.help),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KaziSpacing.screenPadding),
        child: Text(
          l.errorUnknown,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            color: KaziColors.muted,
          ),
        ),
      ),
    );
  }
}

// ── Hub card ──────────────────────────────────────────────────────────────────

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    this.iconColor,
    this.title,
    this.message,
    this.child,
  });

  final IconData icon;
  final Color? iconColor;
  final String? title;
  final String? message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? KaziColors.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: KaziSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: effectiveIconColor),
            ),
            if (title != null) ...[
              const SizedBox(height: KaziSpacing.xl),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: KaziColors.ink,
                ),
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: KaziSpacing.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  color: KaziColors.body,
                ),
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: KaziSpacing.xl),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
