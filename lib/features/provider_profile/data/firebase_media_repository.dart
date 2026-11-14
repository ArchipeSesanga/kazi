import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../domain/media_repository.dart';

class FirebaseMediaRepository implements MediaRepository {
  const FirebaseMediaRepository(this._storage, this._uid);

  final FirebaseStorage _storage;
  final String? _uid;

  static const _maxBytes = 2 * 1024 * 1024;

  @override
  Future<UploadedImage> upload(
    XFile file,
    MediaKind kind, {
    String? listingId,
    void Function(double)? onProgress,
  }) async {
    try {
      final path = _storagePath(kind, listingId: listingId);
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      debugPrint('[MediaRepo] upload: repoUid=$_uid authUid=$authUid path=$path bucket=${_storage.bucket}');
      debugPrint('[MediaRepo] compressing: ${file.path}');
      Uint8List bytes;
      try {
        bytes = await _compress(file.path);
      } catch (e) {
        debugPrint('[MediaRepo] compression failed: $e — trying raw read');
        bytes = await file.readAsBytes();
      }
      debugPrint('[MediaRepo] ready: ${bytes.length} bytes');
      // Retry once on cancellation — the gallery picker causes a background/
      // foreground cycle that can cancel a task created immediately after resume.
      for (var attempt = 0; attempt < 2; attempt++) {
        final ref = _storage.ref(path);
        final task = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        StreamSubscription<TaskSnapshot>? sub;
        if (onProgress != null) {
          sub = task.snapshotEvents.listen((snapshot) {
            if (snapshot.totalBytes > 0) {
              onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
            }
          });
        }
        try {
          final snapshot = await task;
          final url = await snapshot.ref.getDownloadURL();
          return UploadedImage(path: path, url: url);
        } on FirebaseException catch (e) {
          debugPrint('[MediaRepo] FirebaseException: plugin=${e.plugin} code=${e.code} message=${e.message}');
          await sub?.cancel();
          if (e.code == 'canceled' && attempt == 0) {
            await Future<void>.delayed(const Duration(milliseconds: 500));
            continue;
          }
          rethrow;
        } finally {
          await sub?.cancel();
        }
      }
      throw const UnknownException('upload-exhausted');
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<void> delete(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<String> thumbUrl(String path, ThumbSize size) async {
    final segments = path.split('/');
    final filename = segments.last;
    final prefix = size == ThumbSize.small ? 'thumb_200_' : 'thumb_600_';
    final thumbSegments = [...segments]..[segments.length - 1] = '$prefix$filename';
    final thumbPath = thumbSegments.join('/');
    try {
      return await _storage.ref(thumbPath).getDownloadURL();
    } catch (_) {
      return await _storage.ref(path).getDownloadURL();
    }
  }

  String _storagePath(MediaKind kind, {String? listingId}) {
    final uid = _uid;
    if (uid == null) throw const PermissionDeniedException();
    return switch (kind) {
      MediaKind.avatar => 'media/$uid/avatar/avatar.jpg',
      MediaKind.cover => 'media/$uid/cover/cover.jpg',
      MediaKind.portfolio =>
        'media/$uid/portfolio/${DateTime.now().millisecondsSinceEpoch}.jpg',
      MediaKind.listingPhoto =>
        'media/$uid/listings/${listingId ?? 'unknown'}/${DateTime.now().millisecondsSinceEpoch}.jpg',
    };
  }

  static Future<Uint8List> _compress(String filePath) async {
    final result = await FlutterImageCompress.compressWithFile(
      filePath,
      quality: 85,
    );
    if (result == null) throw const UnknownException('image-compress-null');
    if (result.length <= _maxBytes) return result;
    final recompressed = await FlutterImageCompress.compressWithFile(
      filePath,
      quality: 50,
    );
    return recompressed ?? result;
  }
}
