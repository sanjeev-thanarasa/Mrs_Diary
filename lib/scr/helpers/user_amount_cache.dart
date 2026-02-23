class UserAmountCache {
  static final Map<String, Future<Map<String, Object?>?>> _cache = {};

  static Future<Map<String, Object?>?>? get(String userId) {
    return _cache[userId];
  }

  static void set(String userId, Future<Map<String, Object?>?> future) {
    _cache[userId] = future;
  }

  static void invalidate(String userId) {
    _cache.remove(userId);
  }

  static void clear() {
    _cache.clear();
  }
}
