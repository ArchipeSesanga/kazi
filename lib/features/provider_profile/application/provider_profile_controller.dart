import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../domain/provider_repository.dart';

sealed class ProviderProfileState {
  const ProviderProfileState();
}

final class ProviderProfileLoading extends ProviderProfileState {
  const ProviderProfileLoading();
}

final class ProviderProfileLoaded extends ProviderProfileState {
  const ProviderProfileLoaded(this.profile);
  final ProviderProfile profile;
}

final class ProviderProfileNotFound extends ProviderProfileState {
  const ProviderProfileNotFound();
}

final class ProviderProfileError extends ProviderProfileState {
  const ProviderProfileError(this.error);
  final AppException error;
}

class ProviderProfileController extends ChangeNotifier {
  ProviderProfileController(this._repo, this._providerId);

  final ProviderRepository _repo;
  final String _providerId;

  ProviderProfileState _state = const ProviderProfileLoading();
  StreamSubscription<ProviderProfile?>? _sub;

  ProviderProfileState get state => _state;

  void init() {
    _sub?.cancel();
    _sub = _repo.watchProvider(_providerId).listen(
      (profile) {
        _state = profile == null
            ? const ProviderProfileNotFound()
            : ProviderProfileLoaded(profile);
        notifyListeners();
      },
      onError: (Object e, StackTrace s) {
        _state = ProviderProfileError(mapException(e, s));
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
