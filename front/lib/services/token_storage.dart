import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _key = 'access_token';

  // 앱 시작 시 한 번 로드해서 메모리에 캐싱
  static String? _accessToken;

  static Future<void> init() async {
    _accessToken = await _storage.read(key: _key);
  }

  static Future<void> save(String accessToken) async {
    _accessToken = accessToken;
    await _storage.write(key: _key, value: accessToken);
  }

  static Future<void> clear() async {
    _accessToken = null;
    await _storage.delete(key: _key);
  }

  static String? get accessToken => _accessToken;

  static bool get isLoggedIn => _accessToken != null;
}
