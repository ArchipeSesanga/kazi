import 'package:image_picker/image_picker.dart';

enum MediaKind { avatar, cover, portfolio, listingPhoto }

enum ThumbSize { small, large }

class UploadedImage {
  const UploadedImage({required this.path, required this.url});

  final String path;
  final String url;
}

abstract interface class MediaRepository {
  Future<UploadedImage> upload(
    XFile file,
    MediaKind kind, {
    String? listingId,
    void Function(double)? onProgress,
  });
  Future<void> delete(String path);

  /// Deletes a previously uploaded file from its download URL. Only files in
  /// the signed-in user's own `avatar` folder are ever deleted.
  Future<void> deleteAvatarByUrl(String url);
  Future<String> thumbUrl(String path, ThumbSize size);
}
