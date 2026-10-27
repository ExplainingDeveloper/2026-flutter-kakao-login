import 'package:flutter/material.dart';

/// 홈 화면: 로그인한 사용자 정보를 보여준다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO(카카오 4단계): 카카오 사용자 정보 불러오기

  // TODO(카카오 6단계): 로그아웃
  Future<void> _logout() async {}

  // TODO(카카오 6단계): 회원 탈퇴 (카카오 연결 끊기)
  Future<void> _unlink() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: _buildProfile(context, nickname: '닉네임', userId: '-'),
    );
  }

  Widget _buildProfile(
    BuildContext context, {
    required String nickname,
    required String userId,
    String? imageUrl,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null ? const Icon(Icons.person, size: 48) : null,
            ),
            const SizedBox(height: 16),
            Text(nickname, style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '회원번호 $userId',
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _logout,
                child: const Text('로그아웃'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _unlink,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('회원 탈퇴'),
            ),
          ],
        ),
      ),
    );
  }
}
