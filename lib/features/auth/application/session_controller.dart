import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/app_user.dart';
import '../domain/auth_repository.dart';
import '../domain/user_repository.dart';

enum SessionStatus { loading, unauthenticated, profileIncomplete, authenticated }

class SessionController extends ChangeNotifier {
  SessionController(this._userRepo, AuthRepository authRepo) {
    _authSub = authRepo.authStateChanges().listen((authUser) {
      _userSub?.cancel();
      _timeout?.cancel();
      _retryTimer?.cancel();
      _uid = authUser?.uid;
      _authUser = authUser;
      if (authUser == null) {
        _appUser = null;
        _status = SessionStatus.unauthenticated;
        notifyListeners();
      } else {
        _status = SessionStatus.loading;
        notifyListeners();
        _watchUser(authUser.uid);
      }
    });
  }

  final UserRepository _userRepo;
  late final StreamSubscription<AuthUser?> _authSub;
  StreamSubscription<AppUser?>? _userSub;
  Timer? _timeout;
  Timer? _retryTimer;

  SessionStatus _status = SessionStatus.loading;
  String? _uid;
  AppUser? _appUser;
  AuthUser? _authUser;

  SessionStatus get status => _status;
  String? get uid => _uid;
  AppUser? get appUser => _appUser;
  AuthUser? get authUser => _authUser;

  bool get isLoading => _status == SessionStatus.loading;
  bool get isAuthenticated => _status == SessionStatus.authenticated;
  bool get isProfileIncomplete => _status == SessionStatus.profileIncomplete;

  void _watchUser(String uid) {
    _userSub?.cancel();
    _timeout?.cancel();

    _timeout = Timer(const Duration(seconds: 5), () {
      if (_status == SessionStatus.loading) {
        _status = SessionStatus.profileIncomplete;
        notifyListeners();
      }
    });

    _userSub = _userRepo.watchUser(uid).listen(
      (appUser) {
        _timeout?.cancel();
        _retryTimer?.cancel();
        _appUser = appUser;
        _status = (appUser == null || appUser.displayName.trim().isEmpty)
            ? SessionStatus.profileIncomplete
            : SessionStatus.authenticated;
        notifyListeners();
      },
      onError: (Object e) {
        _timeout?.cancel();
        debugPrint('[Session] watchUser error: $e');
        if (_status == SessionStatus.loading) {
          _status = SessionStatus.profileIncomplete;
          notifyListeners();
        }
        // Retry once after a brief delay — the Firestore auth token may not
        // have propagated yet right after sign-in.
        if (_uid == uid) {
          _retryTimer?.cancel();
          _retryTimer = Timer(const Duration(seconds: 1), () {
            if (_uid == uid) _watchUser(uid);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _authSub.cancel();
    _userSub?.cancel();
    _timeout?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}
