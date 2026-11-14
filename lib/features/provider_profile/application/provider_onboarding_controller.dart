import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/application/session_controller.dart';
import '../domain/media_repository.dart';
import '../domain/provider_repository.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController(this._repo, this._session, this._mediaRepo);

  final ProviderRepository _repo;
  final SessionController _session;
  final MediaRepository _mediaRepo;

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

  // Submit
  bool isSubmitting = false;
  bool isDone = false;
  AppException? error;

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
      await _repo.createProvider(profile);
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
