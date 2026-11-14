import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/block_repository.dart';

class BlockController extends ChangeNotifier {
  BlockController(this._repo);
  final BlockRepository _repo;

  Set<String> _blocked = const {};
  StreamSubscription<Set<String>>? _sub;
  String? _uid;

  Set<String> get blockedUids => _blocked;
  bool isBlocked(String uid) => _blocked.contains(uid);

  void init(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _sub?.cancel();
    _sub = null;
    _blocked = const {};
    notifyListeners();
    if (uid == null) return;
    _sub = _repo.watchBlockedUids(uid).listen(
      (set) {
        _blocked = set;
        notifyListeners();
      },
      onError: (Object _, StackTrace __) {},
    );
  }

  Future<void> block(String blockedUid) async {
    if (_uid == null) return;
    await _repo.block(_uid!, blockedUid);
  }

  Future<void> unblock(String blockedUid) async {
    if (_uid == null) return;
    await _repo.unblock(_uid!, blockedUid);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
