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
  Future<String> thumbUrl(String path, ThumbSize size);
}
