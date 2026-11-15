import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_avatar.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/domain/user_repository.dart';
import '../../profile/application/edit_profile_controller.dart';
import '../../provider_profile/domain/media_repository.dart';
import '../../provider_profile/domain/provider_repository.dart';

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
  late final EditProfileController _ctrl;
  final _picker = ImagePicker();
  String? _commune;

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
    _ctrl = EditProfileController(
      context.read<UserRepository>(),
      context.read<ProviderRepository>(),
      context.read<MediaRepository>(),
      context.read<SessionController>(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
    final displayName =
        '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}';
    final ok = await _ctrl.save(displayName: displayName, commune: _commune);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.profileSaved,
            style: const TextStyle(fontFamily: 'Montserrat'),
          ),
          backgroundColor: KaziColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      final message = switch (_ctrl.error?.code) {
        'network' => l.errorNetwork,
        'permissionDenied' => l.errorPermissionDenied,
        _ => l.errorSaveFailed,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Montserrat'),
          ),
          backgroundColor: KaziColors.error,
        ),
      );
    }
  }

  Future<void> _choosePhoto() async {
    final l = AppLocalizations.of(context);
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(l.listingFormPhotoPickGallery),
              onTap: () => Navigator.pop(ctx, _PhotoAction.gallery),
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(l.listingFormPhotoPickCamera),
              onTap: () => Navigator.pop(ctx, _PhotoAction.camera),
            ),
            if (_ctrl.hasPhoto)
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: KaziColors.error),
                title: Text(
                  l.profilePhotoRemove,
                  style: const TextStyle(color: KaziColors.error),
                ),
                onTap: () => Navigator.pop(ctx, _PhotoAction.remove),
              ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    if (action == _PhotoAction.remove) {
      _ctrl.removePhoto();
      return;
    }
    final file = await _picker.pickImage(
      source: action == _PhotoAction.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1600,
    );
    if (file != null) _ctrl.pickPhoto(file);
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
              ListenableBuilder(
                listenable: _ctrl,
                builder: (context, _) => _PhotoPicker(
                  name: context.read<SessionController>().appUser?.displayName ?? '',
                  remoteUrl: _ctrl.photoRemoved ? null : _ctrl.existingPhotoUrl,
                  localPath: _ctrl.pickedPhoto?.path,
                  hasPhoto: _ctrl.hasPhoto,
                  enabled: !_ctrl.isSaving,
                  onTap: _choosePhoto,
                ),
              ),
              const SizedBox(height: KaziSpacing.xl),
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
              ListenableBuilder(
                listenable: _ctrl,
                builder: (context, _) => KaziButton(
                  label: l.profileSaveButton,
                  onPressed: _ctrl.isSaving ? null : _save,
                  isLoading: _ctrl.isSaving,
                ),
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

enum _PhotoAction { gallery, camera, remove }

/// Round profile picture with a camera badge and a text action underneath.
class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.name,
    required this.remoteUrl,
    required this.localPath,
    required this.hasPhoto,
    required this.enabled,
    required this.onTap,
  });

  final String name;
  final String? remoteUrl;
  final String? localPath;
  final bool hasPhoto;
  final bool enabled;
  final VoidCallback onTap;

  static const _size = 104.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: enabled ? onTap : null,
            child: Stack(
              children: [
                if (localPath != null)
                  ClipOval(
                    child: Image.file(
                      File(localPath!),
                      width: _size,
                      height: _size,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  KaziAvatar(name: name, photoUrl: remoteUrl, size: _size),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: KaziColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: KaziColors.surface, width: 2),
                    ),
                    child: const Icon(
                      LucideIcons.camera,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: enabled ? onTap : null,
            child: Text(
              hasPhoto ? l.profilePhotoChange : l.profilePhotoAdd,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
