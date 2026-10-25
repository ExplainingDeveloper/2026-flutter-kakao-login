import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../services/kakao_login_service.dart';
import 'login_screen.dart';

/// 홈 화면: 로그인한 사용자 정보를 보여준다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<User> _userFuture = KakaoLoginService().getUser();

  Future<void> _logout() async {
    await KakaoLoginService().logout();
    if (!mounted) return;
    _goToLogin();
  }

  Future<void> _unlink() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('카카오 계정과의 연결을 끊고 탈퇴할까요?\n다시 로그인하면 동의 화면부터 다시 진행돼요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await KakaoLoginService().unlink();
      if (!mounted) return;
      _goToLogin();
    } catch (error) {
      debugPrint('연결 끊기 실패: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }

  /// 이전 화면 기록을 모두 지우고 로그인 화면으로 이동한다.
  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('사용자 정보 요청 실패: ${snapshot.error}');
            return const Center(child: Text('사용자 정보를 불러오지 못했어요'));
          }
          final user = snapshot.data!;
          final profile = user.kakaoAccount?.profile;
          return _buildProfile(
            context,
            nickname: profile?.nickname ?? '닉네임 없음',
            userId: '${user.id}',
            // 카카오가 http 주소를 주는 경우가 있어 https로 바꾼다. (iOS는 http 이미지를 막는다)
            imageUrl: profile?.profileImageUrl?.replaceFirst('http://', 'https://'),
          );
        },
      ),
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
