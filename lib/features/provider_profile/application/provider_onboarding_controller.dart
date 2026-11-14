import 'package:flutter/foundation.dart';

import '../../auth/application/session_controller.dart';
import '../domain/provider_repository.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController(this._repo, this._session);

  final ProviderRepository _repo;
  final SessionController _session;

  int step = 1;
  static const totalSteps = 3;

  // Step 1
  String displayName = '';
  String bio = '';
  String whatsappNumber = '';
  String callNumber = '';
  int yearsExperience = 0;
  bool hasConsent = false;

  // Step 2
  List<String> categoryIds = [];
  String? baseCommune;
  List<String> communes = [];

  // Submit
  bool isSubmitting = false;
  bool isDone = false;
  bool hasError = false;

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

  void clearError() {
    hasError = false;
    notifyListeners();
  }

  Future<void> submit() async {
    final uid = _session.uid;
    if (uid == null || isSubmitting) return;
    isSubmitting = true;
    hasError = false;
    isDone = false;
    notifyListeners();
    try {
      final profile = ProviderProfile(
        uid: uid,
        displayName: displayName.trim(),
        bio: bio.trim(),
        whatsappNumber: whatsappNumber.trim(),
        callNumber: callNumber.trim().isEmpty ? null : callNumber.trim(),
        yearsExperience: yearsExperience,
        categoryIds: categoryIds,
        baseCommune: baseCommune!,
        communes: communes,
      );
      await _repo.createProvider(profile);
      isDone = true;
    } catch (_) {
      hasError = true;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
