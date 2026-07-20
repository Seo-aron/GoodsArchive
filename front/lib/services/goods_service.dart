import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/goods_item.dart';
import 'api_client.dart';
import 'token_storage.dart';

class GoodsService {
  static Future<List<GoodsItem>> getGoods() async {
    final response = await ApiClient.get('/api/goods');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => GoodsItem.fromJson(json)).toList();
    }
    throw Exception('굿즈 조회 실패 (${response.statusCode})');
  }

  static Future<GoodsItem> registerGoods({
    required XFile image,
    required String name,
    double? price,
    String? memo,
  }) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/goods');
    final request = http.MultipartRequest('POST', uri);

    if (TokenStorage.accessToken != null) {
      request.headers['Authorization'] = 'Bearer ${TokenStorage.accessToken}';
    }

    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.fields['name'] = name;
    if (price != null) request.fields['price'] = price.toStringAsFixed(0);
    if (memo != null && memo.isNotEmpty) request.fields['memo'] = memo;

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return GoodsItem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('굿즈 등록 실패 (${response.statusCode})');
  }

  static Future<GoodsItem> updateGoods(int goodsId, {
    required String name,
    double? price,
    String? memo,
    XFile? image,
  }) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/goods/$goodsId');
    final request = http.MultipartRequest('PUT', uri);

    if (TokenStorage.accessToken != null) {
      request.headers['Authorization'] = 'Bearer ${TokenStorage.accessToken}';
    }

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    request.fields['name'] = name;
    if (price != null) request.fields['price'] = price.toStringAsFixed(0);
    if (memo != null && memo.isNotEmpty) request.fields['memo'] = memo;

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return GoodsItem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('굿즈 수정 실패 (${response.statusCode})');
  }

  static Future<void> deleteGoods(int goodsId) async {
    final response = await ApiClient.delete('/api/goods/$goodsId');
    if (response.statusCode != 204) {
      throw Exception('굿즈 삭제 실패 (${response.statusCode})');
    }
  }
}
