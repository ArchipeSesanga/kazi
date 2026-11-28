import 'package:flutter/foundation.dart';

import '../../../core/constants/limits.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../auth/application/session_controller.dart';
import '../../contact/domain/contact_repository.dart';
import '../domain/review_repository.dart';

/// What the "write a review" screen can show.
enum WriteReviewStatus {
  loading,

  /// Not signed in (the screen asks to sign in).
  signInRequired,

  /// A provider cannot review their own profile.
  ownProfile,

  /// Never contacted this provider: "Contactez ce prestataire pour laisser un avis".
  needsContact,

  /// New review or edit of the existing one.
  ready,

  loadFailed,
}

/// S12 (write / edit / delete). The gate is also in the security rules (a
/// `contacts/{uid}_{providerId}` document must exist); this controller only
/// decides which message to show before the user types anything.
class WriteReviewController extends ChangeNotifier {
  WriteReviewController(
    this._reviews,
    this._contacts,
    this._session, {
    required this.providerId,
  });

  final ReviewRepository _reviews;
  final ContactRepository _contacts;
  final SessionController _session;
  final String providerId;

  WriteReviewStatus _status = WriteReviewStatus.loading;
  Review? _existing;
  int _rating = 0;
  String _text = '';
  bool _isSaving = false;
  AppException? _error;
  bool _done = false;
  bool _disposed = false;

  WriteReviewStatus get status => _status;

  /// The user's current review of this provider, when editing.
  Review? get existing => _existing;
  bool get isEditing => _existing != null;
  int get rating => _rating;
  String get text => _text;
  bool get isSaving => _isSaving;
  AppException? get error => _error;

  /// True after a successful publish or delete: the screen closes.
  bool get done => _done;

  int get textLength => _text.trim().length;
  bool get textTooLong => textLength > Limits.maxReviewTextChars;
  bool get canSubmit =>
      _status == WriteReviewStatus.ready &&
      !_isSaving &&
      _rating >= 1 &&
      _rating <= 5 &&
      !textTooLong;

  Future<void> init() async {
    final uid = _session.uid;
    if (uid == null || !_session.isAuthenticated) {
      return _set(WriteReviewStatus.signInRequired);
    }
    if (uid == providerId) return _set(WriteReviewStatus.ownProfile);
    _set(WriteReviewStatus.loading);
    try {
      final mine = await _reviews.getMine(providerId, uid);
      if (mine != null) {
        _existing = mine;
        _rating = mine.rating;
        _text = mine.text;
        return _set(WriteReviewStatus.ready);
      }
      final contacted = await _contacts.hasContacted(uid, providerId);
      _set(
        contacted ? WriteReviewStatus.ready : WriteReviewStatus.needsContact,
      );
    } catch (e, s) {
      _error = mapException(e, s);
      _set(WriteReviewStatus.loadFailed);
    }
  }

  void setRating(int value) {
    _rating = value.clamp(1, 5);
    _error = null;
    _notify();
  }

  void setText(String value) {
    _text = value;
    _error = null;
    _notify();
  }

  Future<void> submit() async {
    final user = _session.appUser;
    final uid = _session.uid;
    if (!canSubmit || user == null || uid == null) return;
    _isSaving = true;
    _error = null;
    _notify();
    try {
      await _reviews.upsert(
        providerId,
        Review(
          authorUid: uid,
          authorName: user.displayName,
          authorPhotoUrl: user.photoUrl,
          rating: _rating,
          text: _text.trim(),
        ),
      );
      _done = true;
    } catch (e, s) {
      _error = mapException(e, s);
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  Future<void> delete() async {
    final uid = _session.uid;
    if (!isEditing || _isSaving || uid == null) return;
    _isSaving = true;
    _error = null;
    _notify();
    try {
      await _reviews.delete(providerId, uid);
      _done = true;
    } catch (e, s) {
      _error = mapException(e, s);
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  void _set(WriteReviewStatus s) {
    _status = s;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
