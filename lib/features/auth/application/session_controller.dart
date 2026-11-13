import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/auth_repository.dart';

enum SessionStatus { loading, unauthenticated, authenticated }

class SessionController extends ChangeNotifier {
  SessionController(AuthRepository repo) {
    _sub = repo.authStateChanges().listen((user) {
      _status = user == null
          ? SessionStatus.unauthenticated
          : SessionStatus.authenticated;
      _uid = user?.uid;
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthUser?> _sub;
  SessionStatus _status = SessionStatus.loading;
  String? _uid;

  SessionStatus get status => _status;
  String? get uid => _uid;

  bool get isLoading => _status == SessionStatus.loading;
  bool get isAuthenticated => _status == SessionStatus.authenticated;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
