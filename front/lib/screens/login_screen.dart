import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _loginWithKakao() async {
    setState(() => _isLoading = true);

    try {
      OAuthToken token;

      // 카카오앱 설치 여부에 따라 분기
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 백엔드에 카카오 액세스토큰 전달 → 서비스 JWT 발급
      await AuthService.loginWithKakao(token.accessToken);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on KakaoAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 실패: ${e.error}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '나만의 전시장',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '디지털 굿즈를 나만의 공간에',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 60),
            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFFFEE500))
                : GestureDetector(
                    onTap: _loginWithKakao,
                    child: Container(
                      width: 280,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE500),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble, color: Color(0xFF191919), size: 22),
                          SizedBox(width: 10),
                          Text(
                            '카카오로 시작하기',
                            style: TextStyle(
                              color: Color(0xFF191919),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
