import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ApiClient {
  static String get baseUrl {
    if (Platform.isIOS) return 'https://abc123.ngrok-free.app';
    return 'https://abc123.ngrok-free.app';
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (TokenStorage.accessToken != null)
          'Authorization': 'Bearer ${TokenStorage.accessToken}',
      };

  static Future<http.Response> get(String path) =>
      http.get(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(const Duration(seconds: 10));

  static Future<http.Response> put(String path, Object body) =>
      http.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

  static Future<http.Response> post(String path, Object body) =>
      http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

  static Future<http.Response> delete(String path) =>
      http.delete(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(const Duration(seconds: 10));

  /// 상대경로(/uploads/...)를 절대 URL로 변환. 이미 http(s)로 시작하면 그대로 반환.
  static String toAbsoluteUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '$baseUrl$url';
  }
}
