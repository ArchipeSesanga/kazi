import '../../../core/models/app_user.dart';

/// Why [UserRepository.deleteAccount] failed.
enum DeleteAccountFailureReason { recentLoginRequired, notVerified, failed }

class DeleteAccountFailure implements Exception {
  const DeleteAccountFailure(this.reason);

  final DeleteAccountFailureReason reason;

  @override
  String toString() => 'DeleteAccountFailure($reason)';
}

abstract interface class UserRepository {
  Stream<AppUser?> watchUser(String uid);
  Future<void> createUser(AppUser user);
  Future<void> updateUser(String uid, Map<String, dynamic> fields);
  /// Deletes the account and all its data on the server (callable). The
  /// caller must have re-confirmed with a fresh OTP; throws
  /// [DeleteAccountFailure]. Safe to call again after a failure.
  Future<void> deleteAccount();
  Future<void> registerDevice(String uid, String fcmToken);
}
