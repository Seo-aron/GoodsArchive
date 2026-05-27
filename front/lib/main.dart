import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 발급받은 네이티브 앱 키로 교체하세요
  KakaoSdk.init(nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY');

  runApp(const JeonshijangApp());
}

class JeonshijangApp extends StatelessWidget {
  const JeonshijangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '나만의 전시장',
      theme: ThemeData.dark(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainShowcaseScreen(),
      },
    );
  }
}

class MainShowcaseScreen extends StatelessWidget {
  const MainShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' 나의 가상 장식장'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_album),
            onPressed: () {
              print('굿즈 추가 버튼 클릭됨!');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?q=80&w=650'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 20,
                    left: 50,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1608889174637-3c44f6326f1a?q=80&w=150',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 50, color: Colors.red);
                      },
                    ),
                  ),
                  const Positioned(
                    top: 16,
                    left: 16,
                    child: Card(
                      color: Colors.black54,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('현재 테마: 사이버펑크 룸 (예시)'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '내가 보유한 굿즈 목록',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildGoodsRealCard('고양이 피규어', 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=100'),
                        _buildGoodsRealCard('귀여운 키링', 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=100'),
                        _buildGoodsRealCard('건담 로봇', 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=100'),
                        _buildGoodsRealCard('포토 카드', 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=100'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoodsRealCard(String goodsName, String imageUrl) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            goodsName,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
