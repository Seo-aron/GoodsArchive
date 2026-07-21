import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/showcase_screen.dart';
import 'screens/record_screen.dart';
import 'screens/my_info_screen.dart';
import 'services/token_storage.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: '15ee0f3418efcadef9e9c5ab3676c584');
  await TokenStorage.init(); // 디바이스 보안 저장소에서 토큰 복원
  runApp(const ShowcaseApp());
}

// 1. 앱의 진짜 진입점 (테마 및 기본 설정)
class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '피규어 쇼케이스',
      theme: AppTheme.light,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('ko', 'KR'), Locale('en')],
      initialRoute: TokenStorage.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
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
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: '컬렉션',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: '전시장',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '기록',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '내정보',
          ),
        ],
      ),
    );
  }
}

