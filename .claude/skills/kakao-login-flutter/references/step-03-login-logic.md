# 3단계: 카카오 로그인 로직

## 목적

모바일 앱(Android/iOS)에서 아래 두 가지 방식의 카카오 로그인을 구현한다.

| 방식 | API | 동작 |
|---|---|---|
| 카카오톡으로 로그인 (네이티브) | `UserApi.instance.loginWithKakaoTalk()` | 카카오톡 앱을 열어 로그인 |
| 카카오계정으로 로그인 (웹) | `UserApi.instance.loginWithKakaoAccount()` | 기본 브라우저에서 카카오계정 로그인 페이지를 열어 로그인 |

카카오 권장 흐름을 따른다. 카카오톡이 설치되어 있으면 카카오톡으로 로그인하고, 설치되어 있지 않거나 카카오톡 로그인에 실패하면 카카오계정으로 로그인한다.
두 방식 모두 로그인에 성공하면 SDK가 토큰을 받아 `TokenManager`에 자동으로 저장한다.

이 단계의 범위 밖인 것:
- Flutter Web용 `AuthCodeClient.authorize()` 흐름. 인가 코드를 서버에서 토큰으로 바꿔야 해서 구조가 다르다.
- 버튼 이미지 다운로드. 사용자가 0단계에서 직접 받아 `assets/images/kakao/`에 넣는다.

## 사전 확인

- `pubspec.yaml`에 `kakao_flutter_sdk_user`(또는 `kakao_flutter_sdk`)가 있는지 확인한다.
- `main.dart`에 `KakaoSdk.init(`이 있는지 확인한다.
- 둘 중 하나라도 없으면 2단계가 먼저 필요하다고 알린다. "전체" 실행 중이면 2단계에서 이미 처리되었을 것이다.

## A. 로그인 서비스 파일

`lib/services/kakao_login_service.dart`를 만든다.
프로젝트에 이미 정해진 폴더 구조가 있으면(예: `lib/data/`, `lib/features/auth/`) 그 구조를 따른다. 이미 같은 역할의 파일이 있으면 새로 만들지 않고 내용을 확인한다.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오 로그인 처리
class KakaoLoginService {
  /// 카카오톡이 설치되어 있으면 카카오톡으로, 아니면 카카오계정으로 로그인한다.
  ///
  /// 사용자가 로그인을 취소하면 null을 반환한다.
  /// 그 밖의 오류는 호출한 쪽에서 처리할 수 있도록 그대로 던진다.
  Future<OAuthToken?> login() async {
    if (await isKakaoTalkInstalled()) {
      try {
        return await UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        debugPrint('카카오톡으로 로그인 실패: $error');

        // 사용자가 카카오톡 동의 화면에서 취소한 경우에는 의도적인 취소로 보고
        // 카카오계정 로그인을 시도하지 않는다.
        if (_isCanceled(error)) return null;

        // 카카오톡에 연결된 카카오계정이 없는 경우 등은 카카오계정으로 로그인한다.
        return _loginWithKakaoAccount();
      }
    }
    return _loginWithKakaoAccount();
  }

  Future<OAuthToken?> _loginWithKakaoAccount() async {
    try {
      return await UserApi.instance.loginWithKakaoAccount();
    } catch (error) {
      debugPrint('카카오계정으로 로그인 실패: $error');
      if (_isCanceled(error)) return null;
      rethrow;
    }
  }

  bool _isCanceled(Object error) =>
      error is PlatformException && error.code == 'CANCELED';
}
```

이 구조를 쓰는 이유:
- **취소는 null로 반환한다.** 사용자가 취소한 것은 오류가 아니다. 화면에서 "로그인 실패" 메시지를 띄우지 않게 구분한다.
- **카카오톡 로그인에서 취소했으면 카카오계정 로그인을 시도하지 않는다.** 취소했는데 브라우저가 또 열리면 사용자가 당황한다.
- **로그는 `print` 대신 `debugPrint`를 쓴다.** `flutter_lints`의 `avoid_print` 경고를 피한다.

## B. 로그인 버튼

0단계에서 받은 공식 버튼 이미지가 `assets/images/kakao/`에 있는지 확인한다.
- **PNG가 있으면** 이미지 버튼을 만든다 (B-1).
- **없으면** 동작 확인용 임시 텍스트 버튼을 만든다 (B-2). 완료 보고에 0단계 C의 이미지 받는 방법을 다시 안내한다. 이미지를 넣고 3단계를 다시 실행하면 이미지 버튼으로 바뀐다고 알린다.

이미 `KakaoLoginButton`이 있으면 새 파일을 만들지 않는다. 버튼 모양(`build`)과 클래스 주석만 상황에 맞게 바꾼다. 임시 버튼 → 이미지 버튼 전환이 이 경우다.

### B-1. 이미지 버튼

1. **이미지 고르기**
   - PNG가 하나면 그것을 쓴다.
   - 여러 개면 파일 목록과 각 이미지의 픽셀 크기를 보여주고 사용자에게 고르게 한다. 크기는 macOS에서 `sips -g pixelWidth -g pixelHeight <파일>`로 확인한다. 다른 OS에서는 PNG 파일 헤더에서 읽는다(17~20번째 바이트가 가로, 21~24번째 바이트가 세로, 빅엔디언). 크기를 구할 수 없으면 파일 이름만 보여주고 고르게 한다.
     - 공식 파일 이름의 `large`/`medium`/`small`은 버튼 크기 종류이고, `wide`/`narrow`는 가로 길이 종류다. 이름만으로는 어떤 버튼이 화면에 맞을지 판단하기 어렵다.
     - 물어볼 수 없으면 가로 픽셀이 가장 큰 파일을 고르고, 그렇게 골랐다고 알린다. 큰 이미지를 줄여 쓰면 선명하게 보이기 때문이다.
   - 가로가 100픽셀보다 작은 이미지는 공식 버튼 이미지가 아닐 가능성이 높다. 파일이 깨졌거나 잘못 받은 것일 수 있다고 경고한다. 그래도 진행은 한다.

2. **pubspec.yaml에 에셋 등록**
   `flutter:` 섹션 아래에 폴더 단위로 등록한다.
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/images/kakao/
   ```
   - 폴더 경로 끝의 `/`가 있어야 폴더 안의 파일이 모두 포함된다.
   - `assets:` 목록이 이미 있으면 항목만 추가한다.
   - `flutter:` 아래의 다른 설정(`uses-material-design`, `fonts` 등)은 그대로 둔다.
   - 들여쓰기는 공백 2칸이다.

3. **버튼 위젯** – `lib/widgets/kakao_login_button.dart`

```dart
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
        'assets/images/kakao/<파일명>.png',
        height: 48,
        semanticLabel: '카카오 로그인',
      ),
    );
  }
}
```

- `<파일명>`은 실제 파일 이름으로 바꾼다. 경로가 틀리면 analyze는 통과해도 실행할 때 이미지가 깨지므로, 파일이 실제로 있는지 꼭 확인한다.
- `height`만 지정하고 `width`는 지정하지 않는다. 그래야 원본 비율이 유지된다. 카카오 디자인 가이드는 버튼을 늘리거나 찌그러뜨리는 것을 금지한다.
- 둥근 모서리와 노란 배경은 이미지에 이미 들어 있으므로 따로 꾸미지 않는다.
- 사용자에게 보여주는 실패 메시지는 쉬운 말로 쓰고, 자세한 오류는 `debugPrint`로만 남긴다. 사용자에게 원본 오류 문자열을 보여주면 이해하기 어렵다.

### B-2. 임시 텍스트 버튼 (이미지가 없을 때)

B-1과 같은 파일을 만들되, 클래스 주석은 `/// 카카오 로그인 버튼 (임시 디자인)`으로 하고 `build`만 아래로 바꾼다.

```dart
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _onPressed(context),
      child: const Text('카카오 로그인'),
    );
  }
```

이 경우에는 `pubspec.yaml`에 에셋을 등록하지 않는다.

### 공통 메모

- `ScaffoldMessenger`는 `await` 전에 미리 가져온다. `onSuccess` 호출 전에는 `context.mounted`를 확인한다. `await` 뒤에 화면이 사라졌을 수 있고, 확인하지 않으면 `use_build_context_synchronously` 경고가 난다.
- `KakaoLoginButton`의 `const` 생성자는 지우지 않는다. `const` 위젯 트리 안에 버튼을 넣으려면 필요하다.

## C. 화면에 연결

SKILL.md의 "화면 연결 기준"에 따라 결정한다.

### 스타터 프로젝트

`lib/screens/login_screen.dart`의 `// TODO(카카오 3단계): 카카오 로그인 버튼` 줄을 버튼으로 바꾸고 import를 추가한다.

```dart
import '../widgets/kakao_login_button.dart';
```

```dart
              const KakaoLoginButton(),
              // TODO(카카오 4단계): 로그인 성공 시 홈 화면으로 이동
              const SizedBox(height: 48),
```

`TODO(카카오 4단계)` 줄은 남겨 둔다. 이 단계에서는 로그인에 성공하면 "로그인 성공!" 메시지만 뜬다. 4단계에서 홈 화면으로 이동하게 바뀐다.

### 그 외 프로젝트

- `main.dart`가 기본 템플릿(`Text('Hello World!')`나 카운터 예제) 그대로면 그 자리에 `KakaoLoginButton()`을 넣는다. 화면에 `Scaffold`가 있어야 SnackBar가 뜬다. `const` 위젯 트리 안이면 안쪽에는 `const`를 붙이지 않는다(`unnecessary_const` 경고).
- 이미 실제 화면이 있는 앱이면 화면 코드를 바꾸지 않는다. 대신 사용자에게 어디에 버튼을 넣을지 묻는다. 물어볼 수 없으면 아래 사용 예시만 완료 보고에 적는다.

```dart
KakaoLoginButton(
  onSuccess: () {
    // 로그인 성공 후 이동할 화면
  },
)
```

### 다시 실행할 때

이미 버튼이 배치되어 있으면 다시 넣지 않는다.

## 검증

- 이미지 버튼이면 `Image.asset`에 적은 경로의 파일이 실제로 있는지, `pubspec.yaml`에 `assets/images/kakao/`가 등록되었는지 확인한다.
- `flutter analyze`를 실행한다. 새로 만든 파일과 `main.dart`에 에러와 경고가 없어야 한다. 실패하면 고친 뒤 다시 실행한다.
- 앱 실행은 하지 않는다. 실제 로그인은 기기와 카카오 디벨로퍼스 콘솔 설정이 필요해서 사용자가 직접 확인해야 한다.

## 완료 보고에 포함할 내용

- 만든 파일과 버튼을 넣은 위치
- 이미지 버튼인지 임시 버튼인지, 이미지 버튼이면 사용한 파일 이름
- 로그인 흐름 한 줄 요약: "카카오톡 설치 → 카카오톡 로그인 / 미설치·실패 → 카카오계정 로그인 / 취소 → \"취소했어요\" 안내만 (브라우저 로그인 다시 안 띄움)"
- **실제 로그인 전에 콘솔에서 해야 할 일.** 빠뜨리면 로그인이 실패한다.
  - 카카오 디벨로퍼스 > 내 애플리케이션 > [앱] > 카카오 로그인 > **활성화 설정 ON**
  - 동의항목 설정 (예: 닉네임, 프로필 사진)
  - Android 플랫폼 등록: 패키지명과 **키 해시**
    - 키 해시가 없거나 틀리면 로그인이 `invalid android_key_hash or ios_bundle_id or web_site_url` 에러로 실패한다.
    - 다른 컴퓨터에서 빌드했거나 릴리스 키로 빌드했으면, 그 키스토어로 0단계 A-3 방법을 다시 실행해 키 해시를 구하라고 안내한다.
    - Google Play 앱 서명을 쓰면 Play Console에 있는 앱 서명 키의 SHA-1 지문을 같은 방법으로 Base64로 바꿔 등록한다.
    - 디버그 키와 릴리스 키의 해시는 서로 다르므로 둘 다 등록해야 한다.
  - iOS 플랫폼 등록: 번들 ID
- 테스트 방법: 기기나 에뮬레이터에서 `flutter run`으로 실행한 뒤 버튼을 누른다. 카카오톡이 없는 에뮬레이터에서는 브라우저 로그인으로 진행된다.
