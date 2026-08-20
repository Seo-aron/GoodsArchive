import 'dart:convert';
import '../models/showcase_data.dart';
import 'api_client.dart';

class PlaceItemDto {
  final int goodsId;
  final int pageNumber;
  final int shelfNumber;
  final double xPosition;
  final double yPosition;
  final double scale;

  const PlaceItemDto({
    required this.goodsId,
    required this.pageNumber,
    required this.shelfNumber,
    required this.xPosition,
    required this.yPosition,
    required this.scale,
  });

  Map<String, dynamic> toJson() => {
        'goodsId': goodsId,
        'pageNumber': pageNumber,
        'shelfNumber': shelfNumber,
        'xPosition': xPosition,
        'yPosition': yPosition,
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
