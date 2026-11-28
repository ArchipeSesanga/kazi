import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/models/enums.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/domain/user_repository.dart';
import '../../provider_profile/domain/media_repository.dart';
import '../../provider_profile/domain/provider_repository.dart';

/// "Modifier mon profil": name, commune and profile picture.
///
/// The picture is stored on `users/{uid}.photoUrl` (shown on the Profile tab)
/// and, when the user is a provider, on `providers/{uid}.photoUrl`, which
/// `onProviderWritten` then copies to all of the provider's listings. It is
/// uploaded on save (not on pick), like the listing photos.
class EditProfileController extends ChangeNotifier {
  EditProfileController(
    this._users,
    this._providers,
    this._media,
    this._session,
  );

  final UserRepository _users;
  final ProviderRepository _providers;
  final MediaRepository _media;
  final SessionController _session;

  XFile? pickedPhoto;
  bool photoRemoved = false;
  bool isSaving = false;
  AppException? error;

  /// Kept so a retry after a partial failure does not upload again.
  String? _uploadedUrl;

  String? get existingPhotoUrl {
    final url = _session.appUser?.photoUrl;
    return url == null || url.isEmpty ? null : url;
  }

  bool get hasPhoto =>
      pickedPhoto != null || (!photoRemoved && existingPhotoUrl != null);

  bool get photoChanged => pickedPhoto != null || photoRemoved;

  void pickPhoto(XFile file) {
    pickedPhoto = file;
    photoRemoved = false;
    _uploadedUrl = null;
    error = null;
    notifyListeners();
  }

  void removePhoto() {
    pickedPhoto = null;
    _uploadedUrl = null;
    photoRemoved = existingPhotoUrl != null;
    error = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  /// Returns true when everything was saved.
  Future<bool> save({required String displayName, String? commune}) async {
    if (isSaving) return false;
    final uid = _session.uid;
    if (uid == null) return false;
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final oldUrl = existingPhotoUrl;
      String? newUrl;
      if (pickedPhoto != null) {
        newUrl = _uploadedUrl ??=
            (await _media.upload(pickedPhoto!, MediaKind.avatar)).url;
      }

      await _users.updateUser(uid, {
        'displayName': displayName,
        if (commune != null) 'commune': commune,
        if (photoChanged) 'photoUrl': newUrl,
      });

      // Providers: the public profile (and, through onProviderWritten, every
      // listing) must show the same picture.
      if (photoChanged) {
        final provider = await _providers.getProvider(uid);
        if (provider != null && provider.status != ProviderStatus.suspended) {
          await _providers.updateProvider(uid, {'photoUrl': newUrl});
        }
        if (oldUrl != null && oldUrl != newUrl) {
          // Best-effort: an orphaned old file is harmless.
          await _media.deleteAvatarByUrl(oldUrl).catchError((_) {});
        }
      }
      pickedPhoto = null;
      photoRemoved = false;
      _uploadedUrl = null;
      return true;
    } catch (e, s) {
      error = mapException(e, s);
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
