import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../auth/application/session_controller.dart';
import '../../contact/domain/contact_repository.dart';

export '../../contact/domain/contact_repository.dart' show ContactRecord;

sealed class MessagesState {
  const MessagesState();
}

final class MessagesLoading extends MessagesState {
  const MessagesLoading();
}

final class MessagesLoaded extends MessagesState {
  const MessagesLoaded(this.contacts);
  final List<ContactRecord> contacts;
}

final class MessagesError extends MessagesState {
  const MessagesError(this.error);
  final AppException error;
}

class MessagesController extends ChangeNotifier {
  MessagesController(this._repo, this._session);

  final ContactRepository _repo;
  final SessionController _session;

  MessagesState _state = const MessagesLoading();
  StreamSubscription<List<ContactRecord>>? _sub;

  MessagesState get state => _state;

  void init() {
    final uid = _session.uid;
    if (uid == null) {
      _state = const MessagesLoaded([]);
      notifyListeners();
      return;
    }
    _sub?.cancel();
    _sub = _repo.watchContacts(uid).listen(
      (contacts) {
        _state = MessagesLoaded(contacts);
        notifyListeners();
      },
      onError: (Object e, StackTrace s) {
        _state = MessagesError(mapException(e, s));
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
