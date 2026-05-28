import 'package:flutter/material.dart';

class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전시장 꾸미기', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('2D 배경 위에 피규어를 배치하는 화면', style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Text('Step 5 백엔드 완료 후 구현 예정', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
