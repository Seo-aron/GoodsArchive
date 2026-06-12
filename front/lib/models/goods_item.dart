import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class GoodsItem {
  final int id;
  final String name;
  final String imageUrl;
  final double? price;
  final String? purchasedAt;
  final String? memo;

  const GoodsItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.price,
    this.purchasedAt,
    this.memo,
  });

  factory GoodsItem.fromJson(Map<String, dynamic> json) {
    return GoodsItem(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: ApiClient.toAbsoluteUrl(json['imageUrl'] as String),
      price: (json['price'] as num?)?.toDouble(),
      purchasedAt: json['purchasedAt'] as String?,
      memo: json['memo'] as String?,
    );
  }

  String get formattedPrice {
    if (price == null) return '-';
    final p = price!.toInt();
    return '₩${p.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
  }
}
