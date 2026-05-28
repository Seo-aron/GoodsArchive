import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'screens/login_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/showcase_screen.dart';
import 'screens/record_screen.dart';
import 'screens/my_info_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: '15ee0f3418efcadef9e9c5ab3676c584');
  runApp(const ShowcaseApp());
}

// 1. 앱의 진짜 진입점 (테마 및 기본 설정)
class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '피규어 쇼케이스',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MainTabController(),
      },
    );
  }
}

// 2. 화면 하단 탭바를 관리하는 컨트롤러 화면
class MainTabController extends StatefulWidget {
  const MainTabController({super.key});

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0; // 현재 선택된 탭 인덱스

  // 이동할 4개의 화면 리스트 (나중에는 각각 다른 파일로 분리합니다)
  final List<Widget> _screens = [
    const CollectionScreen(),
    const ShowcaseScreen(),
    const RecordScreen(),
    const MyInfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // 현재 인덱스에 맞는 화면을 바디에 뿌려줌
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // 탭을 누르면 화면 전환
          });
        },
        type: BottomNavigationBarType.fixed, // 탭이 4개 이상일 때 고정
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: '컬렉션'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: '전시장'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: '기록'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '내정보'),
        ],
      ),
    );
  }
}

