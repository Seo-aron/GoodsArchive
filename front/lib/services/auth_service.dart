import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'token_storage.dart';

class TokenResponse {
  final String accessToken;
  final String refreshToken;

  TokenResponse({required this.accessToken, required this.refreshToken});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

class AuthService {
  static Future<void> loginWithKakao(String kakaoAccessToken) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/api/auth/kakao'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accessToken': kakaoAccessToken}),
    );

    if (response.statusCode == 200) {
      final token = TokenResponse.fromJson(jsonDecode(response.body));
      await TokenStorage.save(token.accessToken);
      return;
    }
    throw Exception('로그인 실패: ${response.statusCode}');
  }

  static Future<void> register(String loginId, String password, String nickname) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'loginId': loginId, 'password': password, 'nickname': nickname}),
    );
    if (response.statusCode == 200) {
      final token = TokenResponse.fromJson(jsonDecode(response.body));
      await TokenStorage.save(token.accessToken);
      return;
    }
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? '회원가입 실패: ${response.statusCode}');
  }

  static Future<void> loginWithCredentials(String loginId, String password) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'loginId': loginId, 'password': password}),
    );
    if (response.statusCode == 200) {
      final token = TokenResponse.fromJson(jsonDecode(response.body));
      await TokenStorage.save(token.accessToken);
      return;
    }
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? '로그인 실패: ${response.statusCode}');
  }

  static Future<void> logout() => TokenStorage.clear();
}
