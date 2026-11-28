import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/listing.dart';
import '../../../core/state/paged_state.dart';
import '../domain/search_repository.dart';

const _kPageSize = 20;
const _kMinClientResults = 10;
const _kMaxExtraPages = 2;

class FirestoreSearchRepository implements SearchRepository {
  const FirestoreSearchRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Future<PageResult<Listing>> search(
    SearchQuery query, {
    Object? cursor,
  }) async {
    final token = _extractToken(query.keyword);
    final useKeyword = token != null;
    final useCommune = !useKeyword && query.commune != null;

    Query<Map<String, dynamic>> baseQ = _db
        .collection('listings')
        .where('visible', isEqualTo: true)
        .where('city', isEqualTo: query.city);

    if (useKeyword) {
      baseQ = baseQ.where('searchKeywords', arrayContains: token);
      if (query.categoryId != null) {
        baseQ = baseQ.where('categoryId', isEqualTo: query.categoryId);
      }
      baseQ = baseQ.orderBy('ratingScore', descending: true);
    } else if (useCommune) {
      baseQ = baseQ.where('communes', arrayContains: query.commune!);
      if (query.categoryId != null) {
        baseQ = baseQ.where('categoryId', isEqualTo: query.categoryId);
      }
      baseQ = baseQ.orderBy('ratingScore', descending: true);
    } else {
      if (query.categoryId != null) {
        baseQ = baseQ.where('categoryId', isEqualTo: query.categoryId);
      }
      if (query.verifiedOnly) {
        baseQ = baseQ.where('providerVerified', isEqualTo: true);
      }
      baseQ = query.sort == SearchSort.recent
          ? baseQ.orderBy('publishedAt', descending: true)
          : baseQ.orderBy('ratingScore', descending: true);
    }

    final results = <Listing>[];
    DocumentSnapshot? lastDoc = cursor as DocumentSnapshot?;
    var hasMore = false;
    var extraPagesLeft = _kMaxExtraPages;

    while (true) {
      final pageQ = lastDoc != null
          ? baseQ.startAfterDocument(lastDoc).limit(_kPageSize)
          : baseQ.limit(_kPageSize);

      final snap = await pageQ.get();
      hasMore = snap.docs.length == _kPageSize;

      for (final d in snap.docs) {
        final listing = Listing.fromJson({...d.data(), 'id': d.id});
        if (_passesClientFilters(listing, query, useKeyword, useCommune)) {
          results.add(listing);
        }
      }

      lastDoc = snap.docs.isNotEmpty ? snap.docs.last : lastDoc;

      if (results.length >= _kMinClientResults ||
          !hasMore ||
          extraPagesLeft == 0) {
        break;
      }
      extraPagesLeft--;
    }

    return PageResult(items: results, hasMore: hasMore, cursor: lastDoc);
  }

  bool _passesClientFilters(
    Listing listing,
    SearchQuery query,
    bool useKeyword,
    bool useCommune,
  ) {
    if (useKeyword &&
        query.commune != null &&
        !listing.communes.contains(query.commune)) {
      return false;
    }
    if (query.minRating != null && listing.ratingAvg < query.minRating!)
      return false;
    if ((useKeyword || useCommune) &&
        query.verifiedOnly &&
        !listing.providerVerified)
      return false;
    return true;
  }

  String? _extractToken(String? keyword) {
    if (keyword == null || keyword.trim().isEmpty) return null;
    final tokens = _tokenize(keyword);
    if (tokens.isEmpty) return null;
    final longest = tokens.reduce((a, b) => a.length >= b.length ? a : b);
    return longest.length > 15 ? longest.substring(0, 15) : longest;
  }

  List<String> _tokenize(String text) {
    const stopWords = {
      'de',
      'du',
      'des',
      'la',
      'le',
      'les',
      'et',
      'en',
      'a',
      'au',
      'aux',
      'un',
      'une',
      'pour',
      'sur',
      'avec',
      'the',
      'and',
      'of',
      'for',
      'in',
    };
    return _normalize(text)
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2 && !stopWords.contains(t))
        .toSet()
        .toList();
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll(RegExp(r'[ûùü]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9]'), ' ')
        .trim();
  }
}
