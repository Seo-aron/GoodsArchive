import 'dart:convert';
import '../models/user_info.dart';
import 'api_client.dart';

class UserService {
  static Future<UserInfo> getMe() async {
    final response = await ApiClient.get('/api/users/me');
    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('사용자 정보 조회 실패 (${response.statusCode})');
  }
}
