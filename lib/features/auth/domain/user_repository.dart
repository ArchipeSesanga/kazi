import '../../../core/models/app_user.dart';

abstract interface class UserRepository {
  Stream<AppUser?> watchUser(String uid);
  Future<void> createUser(AppUser user);
  Future<void> updateUser(String uid, Map<String, dynamic> fields);
  Future<void> deleteAccount();
  Future<void> registerDevice(String uid, String fcmToken);
}
