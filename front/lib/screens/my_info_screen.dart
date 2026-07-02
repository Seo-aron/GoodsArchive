import 'package:flutter/material.dart';
import '../models/user_info.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  late Future<UserInfo> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = UserService.getMe();
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<UserInfo>(
        future: _userFuture,
        builder: (context, snapshot) {
          final nickname = snapshot.data?.nickname ?? '로딩 중...';
          final imageUrl = snapshot.data?.profileImageUrl;

          return ListView(
            children: [
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          imageUrl != null ? NetworkImage(imageUrl) : null,
                      child: imageUrl == null
                          ? Icon(Icons.person,
                              size: 40, color: Colors.grey.shade400)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(nickname,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    if (snapshot.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('정보를 불러오지 못했습니다',
                            style: TextStyle(
                                color: Colors.red.shade300, fontSize: 12)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text('공지사항'),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('로그아웃',
                    style: TextStyle(color: Colors.red)),
                onTap: () => _logout(context),
              ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }
}
