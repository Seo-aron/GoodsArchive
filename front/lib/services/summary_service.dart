import 'dart:convert';
import '../models/goods_summary.dart';
import 'api_client.dart';

class SummaryService {
  static Future<GoodsSummary> getSummary() async {
    final response = await ApiClient.get('/api/goods/summary');
    if (response.statusCode == 200) {
      return GoodsSummary.fromJson(jsonDecode(response.body));
    }
    throw Exception('요약 조회 실패 (${response.statusCode})');
  }
}
