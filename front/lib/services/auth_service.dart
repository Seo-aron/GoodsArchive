import 'dart:convert';
import 'package:http/http.dart' as http;

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
  // 로컬 개발: Android 에뮬레이터는 10.0.2.2, 실기기는 PC IP로 변경
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static Future<TokenResponse> loginWithKakao(String kakaoAccessToken) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/kakao'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accessToken': kakaoAccessToken}),
    );

    if (response.statusCode == 200) {
      return TokenResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('로그인 실패: ${response.statusCode}');
  }
}
