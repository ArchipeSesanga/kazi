import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../../auth/domain/user_repository.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _controller = TextEditingController();
  bool _deleting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);
    try {
      await context.read<UserRepository>().deleteAccount();
      // SessionController detects auth sign-out and router redirects to welcome.
    } catch (_) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorDeleteFailed,
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
            backgroundColor: KaziColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final confirmWord = l.deleteAccountConfirmWord;

    return Scaffold(
      backgroundColor: KaziColors.surface,
      appBar: AppBar(
        title: Text(
          l.deleteAccountTitle,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        backgroundColor: KaziColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KaziSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(KaziSpacing.lg),
              decoration: BoxDecoration(
                color: KaziColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(KaziSpacing.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: KaziColors.error,
                    size: 22,
                  ),
                  const SizedBox(width: KaziSpacing.md),
                  Expanded(
                    child: Text(
                      l.deleteAccountWarning,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: KaziColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KaziSpacing.xl),
            Text(
              l.deleteAccountConsequences,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: KaziColors.body,
              ),
            ),
            const SizedBox(height: KaziSpacing.xxxl),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                final canDelete = value.text.trim() == confirmWord;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KaziTextField(
                      controller: _controller,
                      label: l.deleteAccountConfirmLabel,
                      hint: confirmWord,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: KaziSpacing.xxxl),
                    KaziButton(
                      label: l.deleteAccountButton,
                      onPressed: (canDelete && !_deleting) ? _delete : null,
                      isLoading: _deleting,
                      variant: KaziButtonVariant.danger,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
