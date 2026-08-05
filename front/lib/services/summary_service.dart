import 'dart:convert';
import '../models/goods_summary.dart';
import '../models/monthly_stats.dart';
import 'api_client.dart';

class SummaryService {
  static Future<GoodsSummary> getSummary() async {
    final response = await ApiClient.get('/api/goods/summary');
    if (response.statusCode == 200) {
      return GoodsSummary.fromJson(jsonDecode(response.body));
    }
    throw Exception('요약 조회 실패 (${response.statusCode})');
  }

  static Future<List<MonthlyStats>> getMonthlyStats() async {
    final response = await ApiClient.get('/api/goods/monthly-stats');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => MonthlyStats.fromJson(json)).toList();
    }
    throw Exception('월별 통계 조회 실패 (${response.statusCode})');
  }
}
