import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/enums.dart';
import '../../auth/application/session_controller.dart';
import '../../provider_profile/domain/media_repository.dart';
import '../domain/listing_repository.dart';

class PhotoEntry {
  const PhotoEntry({
    required this.id,
    this.localFile,
    this.storagePath,
    this.url,
    this.progress,
    this.hasError = false,
  });

  final String id;
  final XFile? localFile;
  final String? storagePath;
  final String? url;
  final double? progress;
  final bool hasError;

  bool get isLocal => localFile != null && url == null;
  bool get isUploading => progress != null;
  bool get isUploaded => url != null && storagePath != null;
  bool get needsUpload => localFile != null && url == null && !hasError;

  PhotoEntry copyWith({
    XFile? localFile,
    String? storagePath,
    String? url,
    double? progress,
    bool? hasError,
    bool clearProgress = false,
    bool clearLocal = false,
  }) =>
      PhotoEntry(
        id: id,
        localFile: clearLocal ? null : (localFile ?? this.localFile),
        storagePath: storagePath ?? this.storagePath,
        url: url ?? this.url,
        progress: clearProgress ? null : (progress ?? this.progress),
        hasError: hasError ?? this.hasError,
      );
}

class ListingFormController extends ChangeNotifier {
  ListingFormController(
    this._listingRepo,
    this._mediaRepo,
    this._session, {
    String? listingId,
  }) {
    _listingId = listingId;
    _startedAsNew = listingId == null;
  }

  final ListingRepository _listingRepo;
  final MediaRepository _mediaRepo;
  final SessionController _session;

  String? _listingId;
  String? get listingId => _listingId;
  bool get isEditing => _listingId != null;
  late final bool _startedAsNew;

  /// Status of the listing as loaded by [init] (edit mode only).
  ListingStatus? _originalStatus;

  /// Editing an active or paused listing: saving keeps its status (the form
  /// shows a single Save button instead of Draft / Publish).
  bool get preservesStatus =>
      _originalStatus != null && _originalStatus != ListingStatus.draft;

  /// Provider's listing count vs the configured limit; loaded for new
  /// listings so the form can explain the limit instead of failing.
  ListingQuota? quota;

  /// True when saving an existing listing (not a draft) succeeded.
  bool savedAsUpdate = false;

  /// New listing, no draft created yet, and the provider is at the limit.
  bool get limitReached =>
      _startedAsNew && _listingId == null && quota?.reached == true;


  String title = '';
  String? categoryId;
  String description = '';
  PriceType priceType = PriceType.fixed;
  String priceAmountText = '';
  Currency currency = Currency.usd;
  List<String> communes = [];
  List<PhotoEntry> photos = [];

  bool isLoading = false;
  bool isSaving = false;
  AppException? error;
  ListingStatus? savedStatus;

  String? titleError;
  String? categoryError;
  String? communeError;

  final List<PhotoEntry> _removedRemotePhotos = [];
  Future<String>? _draftFuture;

  static const _maxPhotos = 6;
  Future<void> _loadQuota() async {
    final uid = _session.uid;
    if (uid == null) return;
    try {
      quota = await _listingRepo.getQuota(uid);
      notifyListeners();
    } on AppException {
      // Advisory only — the rules / onListingWritten still enforce the limit.
    }
  }


  Future<void> init() async {
    if (_listingId == null) {
      await _loadQuota();
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      final listing = await _listingRepo.getListing(_listingId!);
      if (listing != null) {
        _originalStatus = listing.status;
        if (listing.status == ListingStatus.draft) unawaited(_loadQuota());
        title = listing.title;
        categoryId = listing.categoryId;
        description = listing.description;
        priceType = listing.priceType;
        priceAmountText =
            listing.priceAmount != null ? '${listing.priceAmount}' : '';
        currency = listing.currency;
        communes = List.of(listing.communes);
        photos = listing.photos
            .map((p) => PhotoEntry(
                  id: p.id,
                  storagePath: p.path,
                  url: p.url,
                ))
            .toList();
      }
    } on AppException catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Field setters ────────────────────────────────────────────────────────

  void setTitle(String v) {
    title = v;
    titleError = null;
    notifyListeners();
  }

  void setCategory(String id) {
    categoryId = id;
    categoryError = null;
    notifyListeners();
  }

  void setDescription(String v) {
    description = v;
    notifyListeners();
  }

  void setPriceType(PriceType t) {
    priceType = t;
    if (t == PriceType.quote) priceAmountText = '';
    notifyListeners();
  }

  void setPriceAmount(String v) {
    priceAmountText = v;
    notifyListeners();
  }

  void setCurrency(Currency c) {
    currency = c;
    notifyListeners();
  }

  void toggleCommune(String id) {
    if (communes.contains(id)) {
      communes = communes.where((c) => c != id).toList();
    } else if (communes.length < 10) {
      communes = [...communes, id];
    }
    communeError = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  // ── Photos (local only — no upload until save) ───────────────────────────

  bool get canAddPhoto => photos.length < _maxPhotos;

  Future<void> addPhoto(XFile file) async {
    if (!canAddPhoto) return;
    final id = const Uuid().v4();
    photos = [
      ...photos,
      PhotoEntry(id: id, localFile: file),
    ];
    notifyListeners();
  }

  void removePhoto(String id) {
    final entry = photos.where((p) => p.id == id).firstOrNull;
    if (entry == null) return;
    if (entry.isUploaded && !entry.isLocal) {
      _removedRemotePhotos.add(entry);
    }
    photos = photos.where((p) => p.id != id).toList();
    notifyListeners();
  }

  // ── Save / Publish ───────────────────────────────────────────────────────

  Future<void> saveDraft() => _save(ListingStatus.draft);

  Future<void> publish() => _save(ListingStatus.active);

  /// Saves an existing listing keeping its current status.
  Future<void> save() => _save(_originalStatus ?? ListingStatus.draft);

  Future<void> _save(ListingStatus status) async {
    if (isSaving) return;
    if (!_validate()) return;
    final uid = _session.uid;
    if (uid == null) return;
    // Publishing a draft takes a slot (only active + paused count). Without
    // a free one, onListingWritten would hide it, so say so up front.
    final takesSlot = status == ListingStatus.active && !preservesStatus;
    if (limitReached || (takesSlot && quota?.reached == true)) {
      error = const QuotaExceededException('listing_limit');
      notifyListeners();
      return;
    }
    isSaving = true;
    error = null;
    savedStatus = null;
    savedAsUpdate = false;
    notifyListeners();
    try {
      // 1. Ensure draft doc exists.
      final draftId = await _ensureDraft(uid);

      // 2. Upload pending photos sequentially.
      // Reset error state so failed photos from a previous attempt are retried.
      for (final p in photos) {
        if (p.hasError) {
          _updatePhoto(p.id, (e) => e.copyWith(hasError: false));
        }
      }
      var uploadFailed = false;
      for (var i = 0; i < photos.length; i++) {
        final entry = photos[i];
        if (!entry.needsUpload) continue;
        _updatePhoto(entry.id, (e) => e.copyWith(progress: 0, hasError: false));
        try {
          final uploaded = await _mediaRepo.upload(
            entry.localFile!,
            MediaKind.listingPhoto,
            listingId: draftId,
            onProgress: (p) {
              _updatePhoto(entry.id, (e) => e.copyWith(progress: p));
            },
          );
          _updatePhoto(
            entry.id,
            (e) => e.copyWith(
              storagePath: uploaded.path,
              url: uploaded.url,
              clearProgress: true,
              clearLocal: true,
            ),
          );
        } on AppException {
          _updatePhoto(
            entry.id,
            (e) => e.copyWith(hasError: true, clearProgress: true),
          );
          uploadFailed = true;
          break;
        }
      }
      if (uploadFailed) {
        error = const UnknownException('photo-upload');
        return;
      }

      // 3. Update the doc with photos + final fields in one write.
      await _listingRepo.update(draftId, {
        'title': title.trim(),
        'description': description.trim(),
        'categoryId': categoryId,
        'priceType': priceType.name,
        if (priceType != PriceType.quote && priceAmountText.isNotEmpty)
          'priceAmount':
              double.tryParse(priceAmountText.replaceAll(',', '.')) ?? 0.0,
        if (priceType == PriceType.quote) 'priceAmount': FieldValue.delete(),
        'currency': currency == Currency.usd ? 'USD' : 'CDF',
        'communes': communes,
        'photos': photos
            .where((p) => p.isUploaded)
            .map((p) => {'id': p.id, 'path': p.storagePath!, 'url': p.url!})
            .toList(),
        'status': status.name,
      });
      savedStatus = status;
      savedAsUpdate = preservesStatus;

      // 4. Clean up removed remote photos (best-effort).
      for (final removed in _removedRemotePhotos) {
        if (removed.storagePath != null) {
          await _mediaRepo.delete(removed.storagePath!).catchError((_) {});
        }
      }
      _removedRemotePhotos.clear();
    } on AppException catch (e) {
      error = await _explainCreateDenied(e);
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  /// A denied create is most often the listing limit (the counter is updated
  /// server-side, so the form's quota can be stale): say so explicitly.
  Future<AppException> _explainCreateDenied(AppException e) async {
    if (e is! PermissionDeniedException ||
        !_startedAsNew ||
        _listingId != null) {
      return e;
    }
    final uid = _session.uid;
    if (uid == null) return e;
    try {
      final q = await _listingRepo.getQuota(uid);
      quota = q;
      if (q.reached) return const QuotaExceededException('listing_limit');
    } on AppException {
      // keep the original error
    }
    return e;
  }

  /// Creates the draft doc once. Concurrent calls share the same future.
  Future<String> _ensureDraft(String uid) async {
    if (_listingId != null) return _listingId!;
    _draftFuture ??= _createDraft(uid);
    try {
      return await _draftFuture!;
    } catch (_) {
      _draftFuture = null;
      rethrow;
    }
  }

  Future<String> _createDraft(String uid) async {
    final draft = Listing(
      id: '',
      providerId: uid,
      title: title.trim().length >= 4 ? title.trim() : 'draft',
      categoryId: categoryId?.isNotEmpty == true ? categoryId! : 'autres',
      priceType: priceType,
      priceAmount: priceType == PriceType.quote
          ? null
          : double.tryParse(priceAmountText.replaceAll(',', '.')) ?? 0.0,
      city: 'kinshasa',
      communes: communes.isNotEmpty ? communes : ['kinshasa'],
    );
    _listingId = await _listingRepo.createDraft(draft);
    return _listingId!;
  }

  // ── Draft management ─────────────────────────────────────────────────────

  bool get hasDraft => _listingId != null;

  Future<void> discardDraft() async {
    if (_listingId == null) return;
    final id = _listingId!;
    try {
      // Delete uploaded photos from Storage.
      for (final photo in photos) {
        if (photo.storagePath != null) {
          await _mediaRepo.delete(photo.storagePath!).catchError((_) {});
        }
      }
      await _listingRepo.delete(id);
    } catch (e) {
      debugPrint('[ListingForm] discardDraft failed: $e');
    }
    _listingId = null;
    _draftFuture = null;
  }

  // ── Validation ───────────────────────────────────────────────────────────

  bool _validate() {
    var valid = true;
    final trimmed = title.trim();
    if (trimmed.length < 4 || trimmed.length > 80) {
      titleError = 'titleError';
      valid = false;
    }
    if (categoryId == null || categoryId!.isEmpty) {
      categoryError = 'categoryError';
      valid = false;
    }
    if (communes.isEmpty) {
      communeError = 'communeError';
      valid = false;
    }
    if (valid) {
      titleError = null;
      categoryError = null;
      communeError = null;
    }
    notifyListeners();
    return valid;
  }

  void _updatePhoto(String id, PhotoEntry Function(PhotoEntry) fn) {
    photos = photos.map((p) => p.id == id ? fn(p) : p).toList();
    notifyListeners();
  }
}
