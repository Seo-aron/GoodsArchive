import 'package:flutter/material.dart';
import '../models/goods_summary.dart';
import '../services/summary_service.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late Future<GoodsSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = SummaryService.getSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 수집 기록', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _summaryFuture = SummaryService.getSummary();
            }),
          ),
        ],
      ),
      body: FutureBuilder<GoodsSummary>(
        future: _summaryFuture,
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
                  TextButton(
                    onPressed: () => setState(() {
                      _summaryFuture = SummaryService.getSummary();
                    }),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final summary = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('총 자산 가치',
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text(
                          summary.formattedValue,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '총 수집품: ${summary.totalCount}개',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
