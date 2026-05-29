import 'dart:convert';
import '../models/showcase_data.dart';
import 'api_client.dart';

class PlaceItemDto {
  final int goodsId;
  final double positionX;
  final double positionY;
  final double scale;

  const PlaceItemDto({
    required this.goodsId,
    required this.positionX,
    required this.positionY,
    required this.scale,
  });

  Map<String, dynamic> toJson() => {
        'goodsId': goodsId,
        'positionX': positionX,
        'positionY': positionY,
        'scale': scale,
      };
}

class ShowcaseService {
  static Future<ShowcaseData> getMyShowcase() async {
    final response = await ApiClient.get('/api/showcases/mine');
    if (response.statusCode == 200) {
      return ShowcaseData.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('전시장 조회 실패 (${response.statusCode})');
  }

  static Future<ShowcaseData> placeItems(
      int showcaseId, List<PlaceItemDto> items) async {
    final response = await ApiClient.put(
      '/api/showcases/$showcaseId/items',
      {'items': items.map((e) => e.toJson()).toList()},
    );
    if (response.statusCode == 200) {
      return ShowcaseData.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('저장 실패 (${response.statusCode})');
  }
}
