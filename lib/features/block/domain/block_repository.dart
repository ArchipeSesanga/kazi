abstract interface class BlockRepository {
  Stream<Set<String>> watchBlockedUids(String uid);
  Future<void> block(String uid, String blockedUid);
  Future<void> unblock(String uid, String blockedUid);
}
