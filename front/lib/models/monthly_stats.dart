class MonthlyStats {
  final int year;
  final int month;
  final double totalAmount;
  final int goodsCount;

  const MonthlyStats({
    required this.year,
    required this.month,
    required this.totalAmount,
    required this.goodsCount,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      year: json['year'] as int,
      month: json['month'] as int,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      goodsCount: (json['goodsCount'] as num).toInt(),
    );
  }

  String get formattedAmount {
    final v = totalAmount.toInt();
    return '₩${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
  }
}
