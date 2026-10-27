import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/kakao_login_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // runApp() 호출 전 카카오 SDK 초기화
  await KakaoSdk.init(
    nativeAppKey: 'YOUR_NATIVE_APP_KEY',
  );

  // 저장된 카카오 토큰이 유효하면 바로 홈 화면으로 시작한다.
  final isLoggedIn = await KakaoLoginService().hasValidToken();

  runApp(MainApp(isLoggedIn: isLoggedIn));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '카카오 로그인',
      theme: ThemeData(colorSchemeSeed: const Color(0xFFFEE500)),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
