import 'package:flutter/material.dart';

/// 로그인 화면
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                '환영합니다',
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '카카오 계정으로 간편하게 시작하세요',
                style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const Spacer(),
              // TODO(카카오 3단계): 카카오 로그인 버튼
              // TODO(카카오 4단계): 로그인 성공 시 홈 화면으로 이동
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
