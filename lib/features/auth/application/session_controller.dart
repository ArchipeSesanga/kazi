import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/app_user.dart';
import '../domain/auth_repository.dart';
import '../domain/user_repository.dart';

enum SessionStatus { loading, unauthenticated, profileIncomplete, authenticated }

/// Whether `providers/{uid}` exists.
typedef ProviderExists = Future<bool> Function(String uid);

class SessionController extends ChangeNotifier {
  SessionController(
    this._userRepo,
    AuthRepository authRepo, {
    this.providerExists,
  }) {
    _authSub = authRepo.authStateChanges().listen((authUser) {
      // Same user re-emitted (for example a claims refresh): keep the
      // resolved session instead of flashing the splash screen again.
      if (authUser != null && authUser.uid == _uid && !isLoading) {
        _authUser = authUser;
        notifyListeners();
        return;
      }
      if (authUser?.uid != _uid) _providerKnownFor = null;
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
  /// Checks `providers/{uid}` for the provider-space guard.
  final ProviderExists? providerExists;
  String? _providerKnownFor;
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

  /// A signed-in Auth user exists (profile may still be missing).
  bool get hasSession =>
      _authUser != null && _status != SessionStatus.unauthenticated;
  bool get isAdmin => _authUser?.isAdmin ?? false;
  bool get isModerator => _authUser?.isModerator ?? false;

  /// Admin or moderator.
  bool get isStaff => isAdmin || isModerator;

  /// Whether the signed-in user has a `providers/{uid}` document.
  ///
  /// Only a positive answer is cached (per uid): a user who has just finished
  /// onboarding must not be bounced by a stale "no". A negative answer is
  /// re-checked on the next call; a failed check counts as "no" unless the
  /// profile already says `isProvider`.
  Future<bool> hasProviderProfile() async {
    final uid = _uid;
    if (uid == null) return false;
    if (_providerKnownFor == uid) return true;
    var exists = false;
    try {
      exists = await (providerExists?.call(uid) ?? Future.value(false))
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      exists = _appUser?.isProvider ?? false;
    }
    if (exists && _uid == uid) _providerKnownFor = uid;
    return exists;
  }
  bool get isAuthenticated => _status == SessionStatus.authenticated;
  bool get isProfileIncomplete => _status == SessionStatus.profileIncomplete;

  /// Status when there is no usable `users/{uid}` profile. Staff (admin or
  /// moderator claim) sign in with email and have no consumer profile, so they
  /// are not sent to profile setup: the phone-based profile does not apply to
  /// them.
  SessionStatus get _missingProfileStatus =>
      isStaff ? SessionStatus.authenticated : SessionStatus.profileIncomplete;

  void _watchUser(String uid) {
    _userSub?.cancel();
    _timeout?.cancel();

    _timeout = Timer(const Duration(seconds: 5), () {
      if (_status == SessionStatus.loading) {
        _status = _missingProfileStatus;
        notifyListeners();
      }
    });

    _userSub = _userRepo.watchUser(uid).listen(
      (appUser) {
        _timeout?.cancel();
        _retryTimer?.cancel();
        _appUser = appUser;
        _status = (appUser == null || appUser.displayName.trim().isEmpty)
            ? _missingProfileStatus
            : SessionStatus.authenticated;
        notifyListeners();
      },
      onError: (Object e) {
        _timeout?.cancel();
        debugPrint('[Session] watchUser error: $e');
        if (_status == SessionStatus.loading) {
          _status = _missingProfileStatus;
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
