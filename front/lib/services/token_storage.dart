// 메모리 기반 토큰 저장소
// 앱 재시작 시 초기화됨 — 추후 flutter_secure_storage로 교체 권장
class TokenStorage {
  static String? _accessToken;

  static void save(String accessToken) => _accessToken = accessToken;

  static String? get accessToken => _accessToken;

  static bool get isLoggedIn => _accessToken != null;

  static void clear() => _accessToken = null;
}
