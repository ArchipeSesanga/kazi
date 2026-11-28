import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/state/paged_state.dart';
import '../../auth/application/session_controller.dart';
import '../../provider_profile/domain/provider_repository.dart';
import '../domain/review_repository.dart';

/// S12 list: rating summary (from the provider document, server-written) and
/// the paged reviews, newest first.
class ProviderReviewsController extends ChangeNotifier {
  ProviderReviewsController(
    this._reviews,
    this._providers,
    this._session, {
    required this.providerId,
  });

  final ReviewRepository _reviews;
  final ProviderRepository _providers;
  final SessionController _session;
  final String providerId;

  PagedState<Review> _state = const PagedState(isLoadingFirst: true);
  ProviderProfile? _provider;
  bool _disposed = false;

  PagedState<Review> get state => _state;
  ProviderProfile? get provider => _provider;
  double get ratingAvg => _provider?.ratingAvg ?? 0;
  int get ratingCount => _provider?.ratingCount ?? 0;

  /// Signed in, and not the provider themselves.
  bool get canWrite => _session.isAuthenticated && _session.uid != providerId;

  bool isMine(Review r) => r.authorUid == _session.uid;

  Future<void> init() => refresh();

  Future<void> refresh() async {
    _state = const PagedState(isLoadingFirst: true);
    _notify();
    try {
      final results = await Future.wait([
        _providers.getProvider(providerId),
        _reviews.fetch(providerId),
      ]);
      _provider = results[0] as ProviderProfile?;
      final page = results[1] as PageResult<Review>;
      _state = PagedState(
        items: page.items,
        hasMore: page.hasMore,
        cursor: page.cursor,
      );
    } catch (e, s) {
      _state = PagedState(hasMore: false, error: mapException(e, s));
    }
    _notify();
  }

  Future<void> loadMore() async {
    if (_state.isLoadingFirst || _state.isLoadingMore || !_state.hasMore)
      return;
    _state = _state.copyWith(isLoadingMore: true, error: null);
    _notify();
    try {
      final page = await _reviews.fetch(providerId, cursor: _state.cursor);
      _state = _state.copyWith(
        items: [..._state.items, ...page.items],
        hasMore: page.hasMore,
        cursor: page.cursor,
        isLoadingMore: false,
      );
    } catch (e, s) {
      _state = _state.copyWith(isLoadingMore: false, error: mapException(e, s));
    }
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
