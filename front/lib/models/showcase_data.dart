class ShowcasePlacedItem {
  final int id;
  final int goodsId;
  final String goodsName;
  final String goodsImageUrl;
  final double positionX;
  final double positionY;
  final double scale;

  const ShowcasePlacedItem({
    required this.id,
    required this.goodsId,
    required this.goodsName,
    required this.goodsImageUrl,
    required this.positionX,
    required this.positionY,
    required this.scale,
  });

  factory ShowcasePlacedItem.fromJson(Map<String, dynamic> json) {
    return ShowcasePlacedItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      goodsId: (json['goodsId'] as num).toInt(),
      goodsName: json['goodsName'] as String,
      goodsImageUrl: json['goodsImageUrl'] as String,
      positionX: (json['positionX'] as num).toDouble(),
      positionY: (json['positionY'] as num).toDouble(),
      scale: (json['scale'] as num).toDouble(),
    );
  }
}

class ShowcaseData {
  final int id;
  final String name;
  final List<ShowcasePlacedItem> items;

  const ShowcaseData({
    required this.id,
    required this.name,
    required this.items,
  });

  factory ShowcaseData.fromJson(Map<String, dynamic> json) {
    return ShowcaseData(
      id: json['id'] as int,
      name: json['name'] as String,
      items: (json['items'] as List)
          .map((e) => ShowcasePlacedItem.fromJson(e))
          .toList(),
    );
  }
}
