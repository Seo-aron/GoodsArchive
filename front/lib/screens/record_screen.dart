import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/goods_summary.dart';
import '../models/monthly_stats.dart';
import '../services/summary_service.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late Future<(GoodsSummary, List<MonthlyStats>)> _dataFuture;
  int _chartMode = 0; // 0: 지출액, 1: 구입 개수

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
  }

  Future<(GoodsSummary, List<MonthlyStats>)> _load() async {
    final summary = SummaryService.getSummary();
    final monthly = SummaryService.getMonthlyStats();
    return (await summary, await monthly);
  }

  void _refresh() => setState(() => _dataFuture = _load());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 수집 기록', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('데이터를 불러올 수 없습니다',
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _refresh, child: const Text('다시 시도')),
                ],
              ),
            );
          }

          final (summary, monthly) = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 요약 카드
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.inventory_2_outlined,
                        label: '총 굿즈',
                        value: '${summary.totalCount}개',
                        color: cs.primaryContainer,
                        onColor: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: '총 지출',
                        value: summary.formattedValue,
                        color: cs.secondaryContainer,
                        onColor: cs.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 월별 현황 섹션
                const Text('월별 현황',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),

                // 탭 토글
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('지출액'),
                      icon: Icon(Icons.attach_money, size: 16),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('구입 개수'),
                      icon: Icon(Icons.inventory_2_outlined, size: 16),
                    ),
                  ],
                  selected: {_chartMode},
                  onSelectionChanged: (s) =>
                      setState(() => _chartMode = s.first),
                ),
                const SizedBox(height: 24),

                // 차트
                if (monthly.isEmpty)
                  _EmptyChartView()
                else
                  _MonthlyBarChart(
                    data: monthly,
                    showAmount: _chartMode == 0,
                    barColor: cs.primary,
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 요약 카드
// ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color onColor;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: onColor, size: 22),
          const SizedBox(height: 12),
          Text(label,
              style: TextStyle(color: onColor.withAlpha(178), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: onColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 막대그래프
// ─────────────────────────────────────────────
class _MonthlyBarChart extends StatelessWidget {
  final List<MonthlyStats> data;
  final bool showAmount;
  final Color barColor;

  const _MonthlyBarChart({
    required this.data,
    required this.showAmount,
    required this.barColor,
  });

  double get _maxY {
    final max = data.fold(0.0, (prev, e) {
      final v = showAmount ? e.totalAmount : e.goodsCount.toDouble();
      return v > prev ? v : prev;
    });
    return max == 0 ? 10 : max * 1.3;
  }

  String _leftLabel(double value) {
    if (showAmount) {
      if (value >= 10000) return '${(value / 10000).toStringAsFixed(0)}만';
      return value.toInt().toString();
    }
    return '${value.toInt()}개';
  }

  @override
  Widget build(BuildContext context) {
    final groups = data.asMap().entries.map((e) {
      final y = showAmount ? e.value.totalAmount : e.value.goodsCount.toDouble();
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: y,
            color: barColor,
            width: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _maxY,
          barGroups: groups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  final stat = data[i];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${stat.year % 100}년',
                          style: TextStyle(
                              fontSize: 9, color: Colors.grey.shade500),
                        ),
                        Text(
                          '${stat.month}월',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == _maxY) return const SizedBox();
                  return Text(
                    _leftLabel(value),
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.blueGrey.shade700,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final stat = data[groupIndex];
                final label = showAmount
                    ? stat.formattedAmount
                    : '${stat.goodsCount}개';
                return BarTooltipItem(
                  '${stat.year}년 ${stat.month}월\n',
                  const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                  children: [
                    TextSpan(
                      text: label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 데이터 없음 상태
// ─────────────────────────────────────────────
class _EmptyChartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.bar_chart_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('아직 데이터가 없어요',
                style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            Text('굿즈를 등록하면 통계가 표시돼요',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
