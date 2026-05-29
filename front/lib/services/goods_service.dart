import 'dart:convert';
import '../models/goods_item.dart';
import 'api_client.dart';

class GoodsService {
  static Future<List<GoodsItem>> getGoods() async {
    final response = await ApiClient.get('/api/goods');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => GoodsItem.fromJson(json)).toList();
    }
    throw Exception('굿즈 조회 실패 (${response.statusCode})');
  }
}
