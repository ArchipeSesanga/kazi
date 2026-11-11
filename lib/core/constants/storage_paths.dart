// All Cloud Storage paths. No string literals in repositories.
abstract final class StoragePaths {
  static String avatar(String uid, String imageId) =>
      'media/$uid/avatar/$imageId.jpg';
  static String cover(String uid, String imageId) =>
      'media/$uid/cover/$imageId.jpg';
  static String portfolio(String uid, String imageId) =>
      'media/$uid/portfolio/$imageId.jpg';
  static String listingPhoto(String uid, String listingId, String imageId) =>
      'media/$uid/listings/$listingId/$imageId.jpg';

  static String thumb200(String originalPath) {
    final parts = originalPath.split('/');
    final filename = parts.last.replaceFirst('.jpg', '');
    final dir = parts.sublist(0, parts.length - 1).join('/');
    return '$dir/thumbs/${filename}_200x200.webp';
  }

  static String thumb800(String originalPath) {
    final parts = originalPath.split('/');
    final filename = parts.last.replaceFirst('.jpg', '');
    final dir = parts.sublist(0, parts.length - 1).join('/');
    return '$dir/thumbs/${filename}_800x800.webp';
  }

  static String verificationId(String uid, String ts) =>
      'private/verification/$uid/id_$ts.jpg';
  static String verificationSelfie(String uid, String ts) =>
      'private/verification/$uid/selfie_$ts.jpg';
}
