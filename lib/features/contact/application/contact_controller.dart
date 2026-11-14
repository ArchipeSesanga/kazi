import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/launcher_service.dart';
import '../../auth/application/session_controller.dart';
import '../domain/contact_repository.dart';

export '../domain/contact_repository.dart';

class ContactController extends ChangeNotifier {
  ContactController(
    this._launcher,
    this._analytics,
    this._contactRepo,
    this._session,
  );

  final LauncherService _launcher;
  final AnalyticsService _analytics;
  final ContactRepository _contactRepo;
  final SessionController _session;

  Future<void> contactWhatsApp({
    required BuildContext context,
    required String providerId,
    required String providerName,
    String? providerPhotoUrl,
    required String whatsappNumber,
    String? listingId,
    String? listingTitle,
  }) async {
    if (!_session.isAuthenticated) {
      unawaited(context.push(Routes.authPhone));
      return;
    }

    final uid = _session.uid!;
    final l = AppLocalizations.of(context);

    unawaited(_contactRepo.record(ContactDraft(
      clientUid: uid,
      providerId: providerId,
      providerName: providerName,
      providerPhotoUrl: providerPhotoUrl,
      listingId: listingId,
      channel: 'whatsapp',
    )));

    unawaited(_analytics.logContactProvider(
      providerId: providerId,
      channel: 'whatsapp',
      listingId: listingId,
    ));

    final message = listingTitle != null
        ? l.providerWhatsAppMessage(providerName, listingTitle)
        : null;

    try {
      await _launcher.launchWhatsApp(whatsappNumber, message: message);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.contactWhatsAppNotInstalled),
            action: SnackBarAction(
              label: l.contactCopyNumber,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: whatsappNumber));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.contactNumberCopied)),
                  );
                }
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> contactCall({
    required BuildContext context,
    required String providerId,
    required String providerName,
    String? providerPhotoUrl,
    required String phoneNumber,
    String? listingId,
  }) async {
    if (!_session.isAuthenticated) {
      unawaited(context.push(Routes.authPhone));
      return;
    }

    final uid = _session.uid!;

    unawaited(_contactRepo.record(ContactDraft(
      clientUid: uid,
      providerId: providerId,
      providerName: providerName,
      providerPhotoUrl: providerPhotoUrl,
      listingId: listingId,
      channel: 'call',
    )));

    unawaited(_analytics.logContactProvider(
      providerId: providerId,
      channel: 'call',
      listingId: listingId,
    ));

    await _launcher.launchPhone(phoneNumber);
  }
}
