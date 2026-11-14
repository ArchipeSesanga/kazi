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
    this.path,
    this.url,
    this.progress,
    this.hasError = false,
  });

  final String id;
  final String? path;
  final String? url;
  final double? progress;
  final bool hasError;

  bool get isUploading => progress != null;
  bool get isUploaded => url != null && path != null;

  PhotoEntry copyWith({
    String? path,
    String? url,
    double? progress,
    bool? hasError,
    bool clearProgress = false,
  }) =>
      PhotoEntry(
        id: id,
        path: path ?? this.path,
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
  }

  final ListingRepository _listingRepo;
  final MediaRepository _mediaRepo;
  final SessionController _session;

  String? _listingId;
  String? get listingId => _listingId;
  bool get isEditing => _listingId != null;

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

  static const _maxPhotos = 6;

  Future<void> init() async {
    if (_listingId == null) return;
    isLoading = true;
    notifyListeners();
    try {
      final listing = await _listingRepo.getListing(_listingId!);
      if (listing != null) {
        title = listing.title;
        categoryId = listing.categoryId;
        description = listing.description;
        priceType = listing.priceType;
        priceAmountText =
            listing.priceAmount != null ? '${listing.priceAmount}' : '';
        currency = listing.currency;
        communes = List.of(listing.communes);
        photos = listing.photos
            .map((p) => PhotoEntry(id: p.id, path: p.path, url: p.url))
            .toList();
      }
    } on AppException catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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

  bool get canAddPhoto => photos.length < _maxPhotos;

  Future<void> addPhoto(XFile file) async {
    if (!canAddPhoto) return;
    final uid = _session.uid;
    if (uid == null) return;

    final id = const Uuid().v4();
    photos = [...photos, PhotoEntry(id: id, progress: 0.0)];
    notifyListeners();

    try {
      final draftId = await _ensureDraft(uid);
      final uploaded = await _mediaRepo.upload(
        file,
        MediaKind.listingPhoto,
        listingId: draftId,
        onProgress: (p) {
          _updatePhoto(id, (e) => e.copyWith(progress: p));
        },
      );
      _updatePhoto(
        id,
        (e) => e.copyWith(
          path: uploaded.path,
          url: uploaded.url,
          clearProgress: true,
        ),
      );
    } on AppException {
      _updatePhoto(id, (e) => e.copyWith(hasError: true, clearProgress: true));
    }
  }

  Future<void> removePhoto(String id) async {
    final entry = photos.firstWhere((p) => p.id == id, orElse: () => PhotoEntry(id: id));
    photos = photos.where((p) => p.id != id).toList();
    notifyListeners();
    if (entry.path != null) {
      await _mediaRepo.delete(entry.path!).catchError((_) {});
    }
  }

  Future<void> saveDraft() => _save(ListingStatus.draft);

  Future<void> publish() => _save(ListingStatus.active);

  Future<void> _save(ListingStatus status) async {
    if (!_validate()) return;
    final uid = _session.uid;
    if (uid == null) return;
    isSaving = true;
    error = null;
    savedStatus = null;
    notifyListeners();
    try {
      final draftId = await _ensureDraft(uid);
      await _listingRepo.update(draftId, {
        'title': title.trim(),
        'description': description.trim(),
        'categoryId': categoryId,
        'priceType': priceType.name,
        if (priceType != PriceType.quote && priceAmountText.isNotEmpty)
          'priceAmount': double.tryParse(priceAmountText) ?? 0.0,
        if (priceType == PriceType.quote) 'priceAmount': FieldValue.delete(),
        'currency': currency == Currency.usd ? 'USD' : 'CDF',
        'communes': communes,
        'photos': photos
            .where((p) => p.isUploaded)
            .map((p) => {'id': p.id, 'path': p.path!, 'url': p.url!})
            .toList(),
        'status': status.name,
      });
      savedStatus = status;
    } on AppException catch (e) {
      error = e;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<String> _ensureDraft(String uid) async {
    if (_listingId != null) return _listingId!;
    final draft = Listing(
      id: '',
      providerId: uid,
      title: title.trim().isEmpty ? '-' : title.trim(),
      categoryId: categoryId ?? '',
      priceType: priceType,
      city: 'kinshasa',
      communes: communes,
    );
    _listingId = await _listingRepo.createDraft(draft);
    return _listingId!;
  }

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
