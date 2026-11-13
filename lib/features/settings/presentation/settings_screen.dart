import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/domain/user_repository.dart';

// Kinshasa communes from TDD §4.11
const _communes = [
  ('bandalungwa', 'Bandalungwa'),
  ('barumbu', 'Barumbu'),
  ('bumbu', 'Bumbu'),
  ('gombe', 'Gombe'),
  ('kalamu', 'Kalamu'),
  ('kasa_vubu', 'Kasa-Vubu'),
  ('kimbanseke', 'Kimbanseke'),
  ('kinshasa', 'Kinshasa'),
  ('kintambo', 'Kintambo'),
  ('kisenso', 'Kisenso'),
  ('lemba', 'Lemba'),
  ('limete', 'Limete'),
  ('lingwala', 'Lingwala'),
  ('makala', 'Makala'),
  ('maluku', 'Maluku'),
  ('masina', 'Masina'),
  ('matete', 'Matete'),
  ('mont_ngafula', 'Mont-Ngafula'),
  ('ndjili', "N'djili"),
  ('ngaba', 'Ngaba'),
  ('ngaliema', 'Ngaliema'),
  ('ngiri_ngiri', 'Ngiri-Ngiri'),
  ('nsele', 'Nsele'),
  ('selembao', 'Selembao'),
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  String? _commune;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final appUser = context.read<SessionController>().appUser;
    final name = appUser?.displayName ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));
    _firstNameCtrl = TextEditingController(text: parts.isNotEmpty ? parts[0] : '');
    _lastNameCtrl = TextEditingController(
      text: parts.length > 1 ? parts.sublist(1).join(' ') : '',
    );
    _commune = appUser?.commune;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  String? _validateRequired(String? v) {
    if (v == null || v.trim().length < 2) {
      return AppLocalizations.of(context).authProfileNameHint;
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final uid = context.read<SessionController>().uid;
    if (uid == null) return;

    final displayName =
        '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}';

    final fields = <String, dynamic>{'displayName': displayName};
    if (_commune != null) fields['commune'] = _commune;

    try {
      await context.read<UserRepository>().updateUser(uid, fields);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).profileSaved,
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
            backgroundColor: KaziColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorSaveFailed,
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

    return Scaffold(
      backgroundColor: KaziColors.surface,
      appBar: AppBar(
        title: Text(
          l.settingsEditProfile,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KaziTextField(
                controller: _firstNameCtrl,
                label: l.profileFirstNameLabel,
                hint: l.profileFirstNameHint,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: _validateRequired,
              ),
              const SizedBox(height: KaziSpacing.lg),
              KaziTextField(
                controller: _lastNameCtrl,
                label: l.profileLastNameLabel,
                hint: l.profileLastNameHint,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                validator: _validateRequired,
              ),
              const SizedBox(height: KaziSpacing.lg),
              _CommuneDropdown(
                label: l.profileCommuneLabel,
                hint: l.profileCommuneHint,
                value: _commune,
                onChanged: (v) => setState(() => _commune = v),
              ),
              const SizedBox(height: KaziSpacing.xxxl),
              KaziButton(
                label: l.profileSaveButton,
                onPressed: _saving ? null : _save,
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommuneDropdown extends StatelessWidget {
  const _CommuneDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KaziColors.ink,
          ),
        ),
        const SizedBox(height: KaziSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            hint,
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15),
          ),
          isExpanded: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: KaziSpacing.lg,
              vertical: 13,
            ),
          ),
          items: _communes
              .map((c) => DropdownMenuItem(
                    value: c.$1,
                    child: Text(
                      c.$2,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
