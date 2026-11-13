import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/app_user.dart';
import '../domain/auth_repository.dart';
import '../domain/user_repository.dart';

enum SessionStatus { loading, unauthenticated, profileIncomplete, authenticated }

class SessionController extends ChangeNotifier {
  SessionController(AuthRepository authRepo, UserRepository userRepo) {
    _authSub = authRepo.authStateChanges().listen((authUser) {
      _userSub?.cancel();
      _timeout?.cancel();
      _uid = authUser?.uid;
      if (authUser == null) {
        _appUser = null;
        _status = SessionStatus.unauthenticated;
        notifyListeners();
      } else {
        _status = SessionStatus.loading;
        notifyListeners();

        // Fallback: if Firestore doesn't emit within 5 s (e.g. rules deny read),
        // treat the session as profileIncomplete so the user isn't stuck on splash.
        _timeout = Timer(const Duration(seconds: 5), () {
          if (_status == SessionStatus.loading) {
            _status = SessionStatus.profileIncomplete;
            notifyListeners();
          }
        });

        _userSub = userRepo.watchUser(authUser.uid).listen(
          (appUser) {
            _timeout?.cancel();
            _appUser = appUser;
            _status = (appUser == null || appUser.displayName.trim().isEmpty)
                ? SessionStatus.profileIncomplete
                : SessionStatus.authenticated;
            notifyListeners();
          },
          onError: (_) {
            _timeout?.cancel();
            if (_status == SessionStatus.loading) {
              _status = SessionStatus.profileIncomplete;
              notifyListeners();
            }
          },
        );
      }
    });
  }

  late final StreamSubscription<AuthUser?> _authSub;
  StreamSubscription<AppUser?>? _userSub;
  Timer? _timeout;

  SessionStatus _status = SessionStatus.loading;
  String? _uid;
  AppUser? _appUser;

  SessionStatus get status => _status;
  String? get uid => _uid;
  AppUser? get appUser => _appUser;

  bool get isLoading => _status == SessionStatus.loading;
  bool get isAuthenticated => _status == SessionStatus.authenticated;
  bool get isProfileIncomplete => _status == SessionStatus.profileIncomplete;

  @override
  void dispose() {
    _authSub.cancel();
    _userSub?.cancel();
    _timeout?.cancel();
    super.dispose();
  }
}
