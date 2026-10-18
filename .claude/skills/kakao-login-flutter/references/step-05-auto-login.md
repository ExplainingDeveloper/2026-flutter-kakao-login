# 5단계: 자동 로그인 (토큰 확인)

## 목적

앱을 다시 켰을 때 이전 로그인이 아직 유효하면 로그인 화면을 건너뛰고 바로 홈 화면으로 보낸다.

로그인에 성공하면 SDK가 토큰을 기기에 저장한다. 하지만 토큰이 **있다고 해서 유효한 것은 아니다.** 만료됐거나 사용자가 카카오 쪽에서 연결을 끊었을 수 있다.
그래서 공식 문서의 권장대로 두 단계로 확인한다.
1. `AuthApi.instance.hasToken()`: 저장된 토큰이 있는지
2. `UserApi.instance.accessTokenInfo()`: 그 토큰이 실제로 유효한지 (서버 확인)

액세스 토큰만 만료된 경우에는 SDK가 리프레시 토큰으로 갱신을 시도한다. 리프레시 토큰까지 만료되었으면 다시 로그인해야 한다.

## 사전 확인

`lib/services/kakao_login_service.dart`(3단계)가 있어야 한다. 스타터 프로젝트라면 4단계도 끝나 있어야 한다. 없으면 필요한 단계를 먼저 하라고 알린다.

## A. 서비스에 메서드 추가

`KakaoLoginService`에 아래 메서드를 추가한다. 이미 있으면 건너뛴다.

```dart
  /// 저장된 토큰이 있고 아직 유효하면 true를 반환한다.
  ///
  /// false이면 다시 로그인해야 한다.
  Future<bool> hasValidToken() async {
    if (!await AuthApi.instance.hasToken()) return false;
    try {
      // 네트워크가 느리면 스플래시 화면이 오래 멈춰 있지 않도록 5초까지만 기다린다.
      await UserApi.instance.accessTokenInfo().timeout(const Duration(seconds: 5));
      return true;
    } catch (error) {
      if (error is KakaoException && error.isInvalidTokenError()) {
        debugPrint('카카오 토큰 만료: 다시 로그인이 필요해요');
      } else {
        debugPrint('카카오 토큰 확인 실패: $error');
      }
      return false;
    }
  }
```

토큰이 만료된 것이 아닌 다른 오류(예: 인터넷 끊김, 5초 초과)도 `false`로 처리한다. 사용자는 로그인 화면을 보게 되고, 다시 로그인하면 된다. 확인되지 않은 상태로 홈 화면에 보내면 사용자 정보 요청이 실패한다.

## B. 시작 화면 결정

### 스타터 프로젝트: main.dart 수정

`runApp()` 전에 토큰을 확인해서 시작 화면을 고른다. 확인하는 동안에는 네이티브 스플래시 화면이 그대로 보인다.
`// TODO(카카오 5단계)` 두 줄을 아래처럼 바꾼다.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await KakaoSdk.init(nativeAppKey: '...'); // 2단계에서 넣은 그대로

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
      // title, theme 등 기존 설정은 그대로
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
```

- `KakaoSdk.init`은 반드시 `hasValidToken()`보다 먼저 호출해야 한다. SDK가 초기화되기 전에는 API를 쓸 수 없다.
- 2단계에서 넣은 키 값과 주석은 그대로 둔다. 위 예시의 `'...'`로 바꾸지 않는다.
- `services/kakao_login_service.dart`, `screens/home_screen.dart` import를 추가한다.
- `MaterialApp`의 다른 설정(`title`, `theme` 등)은 그대로 둔다.

### 그 외 프로젝트

`main.dart`나 라우팅 코드를 바꾸지 않는다. 대신 아래 사용 예시를 완료 보고에 적는다. 앱의 스플래시 화면이나 라우터 초기화에서 호출하면 된다.

```dart
final isLoggedIn = await KakaoLoginService().hasValidToken();
// true → 메인 화면, false → 로그인 화면
```

## 검증

- `flutter analyze`를 실행한다. 에러와 경고가 없어야 한다.
- `main()`에서 `KakaoSdk.init` → `hasValidToken()` → `runApp()` 순서인지 확인한다.

## 완료 보고에 포함할 내용

- 추가한 메서드와 `main.dart` 변경 부분
- 동작 요약: "앱 시작 → 토큰 있음 + 유효 → 홈 화면 / 그 외 → 로그인 화면"
- 테스트 방법: 로그인한 뒤 앱을 완전히 종료하고 다시 실행하면 바로 홈 화면이 떠야 한다.
