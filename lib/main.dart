import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  // TODO(카카오 2단계): 카카오 SDK 초기화
  // TODO(카카오 5단계): 자동 로그인 확인
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '카카오 로그인',
      theme: ThemeData(colorSchemeSeed: const Color(0xFFFEE500)),
      // TODO(카카오 5단계): 로그인 상태에 따라 시작 화면 고르기
      home: const LoginScreen(),
    );
  }
}
