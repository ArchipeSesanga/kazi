import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../features/provider_profile/domain/provider_repository.dart';

class PublishHubController extends ChangeNotifier {
  PublishHubController(this._repo);

  final ProviderRepository _repo;

  bool isLoading = true;
  ProviderProfile? profile;
  bool hasError = false;
  StreamSubscription<ProviderProfile?>? _sub;

  void init(String uid) {
    _sub?.cancel();
    isLoading = true;
    hasError = false;
    notifyListeners();
    _sub = _repo.watchProvider(uid).listen(
      (p) {
        isLoading = false;
        profile = p;
        notifyListeners();
      },
      onError: (Object _, StackTrace __) {
        isLoading = false;
        hasError = true;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
