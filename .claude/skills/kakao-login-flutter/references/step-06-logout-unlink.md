# 6단계: 로그아웃 / 연결 끊기

## 목적

| 기능 | API | 하는 일 |
|---|---|---|
| 로그아웃 | `UserApi.instance.logout()` | 기기에 저장된 토큰을 지운다. 카카오 계정과 앱의 연결은 유지된다. 다시 로그인하면 동의 화면 없이 바로 로그인된다. |
| 연결 끊기 | `UserApi.instance.unlink()` | 앱과 카카오 계정의 연결을 끊는다. 동의 내역과 토큰이 모두 사라진다. 다시 로그인하면 동의 화면부터 다시 나온다. 보통 "회원 탈퇴"에 쓴다. |

연결 끊기가 중요한 이유가 있다. iOS App Store 심사 기준은 앱 안에서 회원가입을 받으면 앱 안에서 계정 삭제도 할 수 있어야 한다고 요구한다.

## 사전 확인

`lib/services/kakao_login_service.dart`(3단계)가 있어야 한다.

## A. 서비스에 메서드 추가

`KakaoLoginService`에 아래 메서드를 추가한다. 이미 있으면 건너뛴다.

```dart
  /// 로그아웃한다.
  ///
  /// 서버 요청이 실패해도 SDK가 기기에 저장된 토큰은 지우므로, 로그아웃된 것으로 본다.
  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
    } catch (error) {
      debugPrint('로그아웃 요청 실패 (기기의 토큰은 삭제됨): $error');
    }
  }

  /// 앱과 카카오 계정의 연결을 끊는다. (회원 탈퇴)
  ///
  /// 실패하면 연결이 그대로 남아 있으므로 오류를 그대로 던진다.
  Future<void> unlink() async {
    await UserApi.instance.unlink();
  }
```

두 메서드가 오류를 다르게 처리하는 이유가 있다. SDK의 `logout()`은 서버 요청이 실패해도 기기의 토큰을 지운다. `unlink()`는 성공했을 때만 토큰을 지운다. 그래서 연결 끊기가 실패하면 "탈퇴 실패"를 알려야 한다.

## B. 화면 배치

### 스타터 프로젝트: 홈 화면 버튼 연결

로그아웃과 회원 탈퇴 버튼은 스타터의 `lib/screens/home_screen.dart`에 이미 있다. 빈 메서드만 채운다.

1. `import 'login_screen.dart';`를 추가한다.
2. `// TODO(카카오 6단계)` 주석과 빈 `_logout`, `_unlink` 메서드를 아래로 바꾼다.

```dart
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
```

이렇게 만든 이유:
- **탈퇴는 확인 창을 먼저 띄운다.** 되돌릴 수 없는 동작이라 실수로 누르는 것을 막는다.
- **이동할 때 `pushAndRemoveUntil`을 쓴다.** 로그아웃한 뒤 뒤로 가기로 홈 화면에 돌아오지 못하게 한다.

### 그 외 프로젝트

화면 파일을 만들지 않는다. 대신 아래 사용 예시를 완료 보고에 적는다.

```dart
await KakaoLoginService().logout();  // 로그아웃
await KakaoLoginService().unlink();  // 회원 탈퇴 (실패하면 예외 발생)
```

## 검증

- `flutter analyze`를 실행한다. 에러와 경고가 없어야 한다.
- `await` 뒤에 `context`를 쓰기 전에 `mounted`를 확인했는지 본다.

## 완료 보고에 포함할 내용

- 추가한 메서드와 연결한 버튼
- 로그아웃과 연결 끊기의 차이를 한 줄로 설명
- **자체 서버가 있다면** 안내할 것: 연결 끊기는 카카오와의 연결만 끊는다. 서비스 서버에 저장된 회원 데이터 삭제는 직접 구현해야 한다.
- 테스트 방법
  - 로그아웃 후 다시 로그인하면 동의 화면 없이 바로 로그인된다.
  - 탈퇴 후 다시 로그인하면 동의 화면이 다시 나온다.
