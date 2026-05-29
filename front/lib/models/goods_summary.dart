class GoodsSummary {
  final int totalCount;
  final double totalValue;

  const GoodsSummary({required this.totalCount, required this.totalValue});

  factory GoodsSummary.fromJson(Map<String, dynamic> json) {
    return GoodsSummary(
      totalCount: json['totalCount'] as int,
      totalValue: (json['totalValue'] as num).toDouble(),
    );
  }

  String get formattedValue {
    final v = totalValue.toInt();
    return '₩ ${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
  }
}
