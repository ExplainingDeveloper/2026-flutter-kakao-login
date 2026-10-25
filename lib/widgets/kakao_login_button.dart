import 'package:flutter/material.dart';

import '../services/kakao_login_service.dart';

/// 카카오 로그인 버튼 (공식 버튼 이미지)
class KakaoLoginButton extends StatelessWidget {
  const KakaoLoginButton({super.key, this.onSuccess});

  /// 로그인에 성공했을 때 호출된다. 없으면 "로그인 성공" 메시지만 띄운다.
  final VoidCallback? onSuccess;

  Future<void> _onPressed(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final token = await KakaoLoginService().login();
      if (token == null) {
        messenger.showSnackBar(const SnackBar(content: Text('로그인을 취소했어요')));
        return;
      }
      if (!context.mounted) return;
      if (onSuccess != null) {
        onSuccess!();
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('로그인 성공!')));
      }
    } catch (error) {
      debugPrint('카카오 로그인 실패: $error');
      messenger.showSnackBar(
        const SnackBar(content: Text('로그인에 실패했어요. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onPressed(context),
      child: Image.asset(
        'assets/images/kakao/kakao_login_kr_large.png',
        height: 48,
        semanticLabel: '카카오 로그인',
      ),
    );
  }
}
