import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/domain/user_repository.dart';
import '../domain/media_repository.dart';
import '../domain/provider_repository.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController(
    this._repo,
    this._session,
    this._mediaRepo,
    this._users,
  ) {
    // The account already has a profile picture: show it in the picker and
    // use it for the provider profile, no new upload needed.
    photoUrl = _accountPhotoUrl;
  }

  final ProviderRepository _repo;
  final SessionController _session;
  final MediaRepository _mediaRepo;
  final UserRepository _users;

  /// The signed-in account's current picture (`users/{uid}.photoUrl`).
  String? get _accountPhotoUrl {
    final url = _session.appUser?.photoUrl;
    return url == null || url.isEmpty ? null : url;
  }

  int step = 1;
  static const totalSteps = 3;

  // Step 1
  String displayName = '';
  String bio = '';
  String whatsappNumber = '';
  String callNumber = '';
  int yearsExperience = 0;
  bool hasConsent = false;

  // Photos — local until submit
  XFile? avatarFile;
  XFile? coverFile;
  String? photoUrl;
  String? coverUrl;
  double? avatarUploadProgress;
  double? coverUploadProgress;

  // Step 2
  List<String> categoryIds = [];
  String? baseCommune;
  List<String> communes = [];

  // Resubmit (entry found an existing `rejected` doc)
  bool isResubmitting = false;

  // Submit
  bool isSubmitting = false;
  bool isDone = false;
  AppException? error;

  /// Prefills the form from a previously-rejected profile so the user can
  /// edit and resubmit rather than create a duplicate doc.
  void prefillForResubmit(ProviderProfile profile) {
    isResubmitting = true;
    displayName = profile.displayName;
    bio = profile.bio;
    photoUrl = profile.photoUrl ?? _accountPhotoUrl;
    coverUrl = profile.coverUrl;
    whatsappNumber = profile.whatsappNumber;
    callNumber = profile.callNumber ?? '';
    yearsExperience = profile.yearsExperience;
    categoryIds = List.of(profile.categoryIds);
    baseCommune = profile.baseCommune;
    communes = List.of(profile.communes);
    hasConsent = true;
    notifyListeners();
  }

  void goToStep(int s) {
    step = s;
    notifyListeners();
  }

  void setConsent(bool value) {
    hasConsent = value;
    notifyListeners();
  }

  void incrementYears() {
    if (yearsExperience < 60) {
      yearsExperience++;
      notifyListeners();
    }
  }

  void decrementYears() {
    if (yearsExperience > 0) {
      yearsExperience--;
      notifyListeners();
    }
  }

  void toggleCategory(String id) {
    if (categoryIds.contains(id)) {
      categoryIds = categoryIds.where((c) => c != id).toList();
    } else if (categoryIds.length < 3) {
      categoryIds = [...categoryIds, id];
    }
    notifyListeners();
  }

  void setBaseCommune(String id) {
    baseCommune = id;
    if (!communes.contains(id)) {
      communes = [id, ...communes.where((c) => c != id)];
    }
    notifyListeners();
  }

  void toggleCommune(String id) {
    if (communes.contains(id)) {
      if (id == baseCommune) return;
      communes = communes.where((c) => c != id).toList();
    } else if (communes.length < 10) {
      communes = [...communes, id];
    }
    notifyListeners();
  }

  void pickAvatar(XFile file) {
    avatarFile = file;
    photoUrl = null;
    notifyListeners();
  }

  void pickCover(XFile file) {
    coverFile = file;
    coverUrl = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  /// The provider's picture is also the account's: a picture picked here
  /// becomes the profile picture when the account has none, and replaces it
  /// when the user chose a different one. Unchanged → nothing to do.
  /// Best-effort: the provider profile is already saved at this point.
  Future<void> _syncAccountPhoto(String uid) async {
    final url = photoUrl;
    final old = _accountPhotoUrl;
    if (url == null || url == old) return;
    try {
      await _users.updateUser(uid, {'photoUrl': url});
      if (old != null) {
        await _mediaRepo.deleteAvatarByUrl(old).catchError((_) {});
      }
    } catch (e) {
      debugPrint('[Onboarding] account photo sync failed: $e');
    }
  }

  Future<void> submit() async {
    final uid = _session.uid;
    if (uid == null || isSubmitting) return;
    isSubmitting = true;
    error = null;
    isDone = false;
    notifyListeners();
    try {
      // Upload avatar if picked and not yet uploaded.
      if (avatarFile != null && photoUrl == null) {
        avatarUploadProgress = 0;
        notifyListeners();
        final result = await _mediaRepo.upload(
          avatarFile!,
          MediaKind.avatar,
          onProgress: (p) {
            avatarUploadProgress = p;
            notifyListeners();
          },
        );
        photoUrl = result.url;
        avatarFile = null;
        avatarUploadProgress = null;
        notifyListeners();
      }

      // Upload cover if picked and not yet uploaded.
      if (coverFile != null && coverUrl == null) {
        coverUploadProgress = 0;
        notifyListeners();
        final result = await _mediaRepo.upload(
          coverFile!,
          MediaKind.cover,
          onProgress: (p) {
            coverUploadProgress = p;
            notifyListeners();
          },
        );
        coverUrl = result.url;
        coverFile = null;
        coverUploadProgress = null;
        notifyListeners();
      }

      final profile = ProviderProfile(
        uid: uid,
        displayName: displayName.trim(),
        bio: bio.trim(),
        photoUrl: photoUrl,
        coverUrl: coverUrl,
        whatsappNumber: whatsappNumber.trim(),
        callNumber: callNumber.trim().isEmpty ? null : callNumber.trim(),
        yearsExperience: yearsExperience,
        categoryIds: categoryIds,
        baseCommune: baseCommune!,
        communes: communes,
      );
      if (isResubmitting) {
        // rejected → pending is the only status transition the rules allow
        // a client to make; everything else is a normal field update.
        await _repo.updateProvider(uid, {
          ...profile.toUpdateMap(),
          'status': 'pending',
        });
      } else {
        await _repo.createProvider(profile);
      }
      await _syncAccountPhoto(uid);
      isDone = true;
    } on AppException catch (e) {
      error = e;
    } catch (e, s) {
      debugPrint('[Onboarding] submit failed: $e\n$s');
      error = const UnknownException('submit');
    } finally {
      avatarUploadProgress = null;
      coverUploadProgress = null;
      isSubmitting = false;
      notifyListeners();
    }
  }
}
