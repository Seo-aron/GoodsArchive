import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ApiClient {
  static String get baseUrl {
    if (Platform.isIOS) return 'http://localhost:8080';
    return 'http://192.168.1.49:8080'; // 실기기 IP — 에뮬레이터는 10.0.2.2로 변경
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
}
