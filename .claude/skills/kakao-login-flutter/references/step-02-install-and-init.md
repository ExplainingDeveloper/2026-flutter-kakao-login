# 2단계: SDK 설치 및 초기화

## 목적

카카오 Flutter SDK 패키지를 프로젝트에 추가하고, 앱이 시작될 때 `KakaoSdk.init()`으로 SDK를 초기화한다.
초기화를 하지 않으면 로그인 API를 호출할 때 에러가 난다.

## 필요한 정보

- `NATIVE_APP_KEY`: SKILL.md의 "공통 정보 모으기"에서 받은 값.
  1단계에서 스킴에 넣은 키와 **정확히 같아야** 한다. 다르면 카카오톡 로그인 후 앱으로 돌아오지 못한다.
- `JAVASCRIPT_APP_KEY`: 웹도 서비스할 때만 필요하다. 아래 "앱 키 결정"을 본다.

## A. 패키지 설치

### 설치할 패키지 고르기

필요한 패키지만 설치한다. 전체 패키지(`kakao_flutter_sdk`)는 쓰지 않는 기능까지 포함해서 앱이 무거워진다.

| 패키지 | 언제 |
|---|---|
| `kakao_flutter_sdk_user` | 항상 (카카오 로그인 API) |
| `kakao_flutter_sdk_share` | 카카오톡 공유를 쓸 때만 |

카카오톡 공유 사용 여부는 새로 묻지 않는다.
- 1단계에서 받은 답이 있으면 그 답을 쓴다.
- 없으면 `AndroidManifest.xml`이나 `ios/Runner/Info.plist`에 `kakaolink`가 있는지로 판단한다.

사용자가 전체 패키지를 원한다고 직접 말하면 `kakao_flutter_sdk`를 설치한다.

### 이미 설치되어 있는지 확인

`pubspec.yaml`의 `dependencies`에 `kakao_flutter_sdk`, `kakao_flutter_sdk_user` 등이 이미 있으면 그 패키지는 다시 추가하지 않는다.
전체 패키지(`kakao_flutter_sdk`)가 이미 있으면 바꾸지 않고 그대로 쓴다. 사용자가 일부러 넣었을 수 있다. 완료 보고에 "로그인만 쓰면 `kakao_flutter_sdk_user`로 바꿔 앱을 가볍게 할 수 있다"고 한 줄 안내한다.

### 설치 명령

아래 중 하나만 실행한다.

```bash
# 로그인만 쓸 때
flutter pub add kakao_flutter_sdk_user

# 카카오톡 공유도 쓸 때
flutter pub add kakao_flutter_sdk_user kakao_flutter_sdk_share
```

`flutter pub add`를 쓰는 이유가 있다.
- 현재 Dart/Flutter 버전과 호환되는 최신 버전을 알아서 고른다.
- `pubspec.yaml`의 들여쓰기도 올바르게 넣는다.
- `flutter pub get`까지 자동으로 실행한다.

버전 번호를 직접 추측해서 적지 않는다.

`flutter` 명령을 찾을 수 없으면 아래 순서로 진행한다.
1. `https://pub.dev/api/packages/<패키지명>`에서 `latest.version`을 확인한다.
2. `pubspec.yaml`의 `dependencies:` 아래에 `  kakao_flutter_sdk_user: ^<버전>` 형식으로 직접 추가한다. 들여쓰기는 공백 2칸이다.
3. 사용자에게 `flutter pub get`을 직접 실행해 달라고 안내한다.

### 설치 확인

- 명령 출력에 에러가 없는지 확인한다.
- `pubspec.yaml`에 패키지가 들어갔는지 확인한다.

버전 충돌로 실패하면 출력의 원인(예: Dart SDK 버전 제약)을 한국어로 풀어서 설명하고 멈춘다.

## B. 초기화 (main.dart)

대상 파일: `lib/main.dart`

`runApp()`이 있는 파일이 다르면 그 파일을 고친다.

### 앱 키 결정

프로젝트에 `web/` 폴더가 있는지로 판단한다.

| 상황 | init() 파라미터 |
|---|---|
| `web/` 없음 (네이티브 앱만) | `nativeAppKey`만 |
| `web/` 있음 | 사용자에게 웹도 서비스할지 묻는다. 웹도 서비스하면 JavaScript 키를 받아 `nativeAppKey`와 `javaScriptAppKey`를 함께 전달한다 |

JavaScript 키의 위치는 **카카오 디벨로퍼스 > 내 애플리케이션 > [앱] > 플랫폼 키 > JavaScript 키**다. 형식 검증은 네이티브 앱 키와 같다.
네이티브 앱 키와 같은 값을 입력했으면 다시 받는다. 두 키는 서로 다르다.

### import

설치한 패키지의 대표 파일을 import한다.
- `kakao_flutter_sdk_user`를 설치했으면 `import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';`
- 전체 패키지(`kakao_flutter_sdk`)를 설치했으면 `import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';`
- `kakao_flutter_sdk_share`도 설치했더라도 `main.dart`에서는 위 하나만 import한다. 공유 API를 쓰지 않는 파일에서 import하면 `unused_import` 경고가 난다.

공식 문서 예시는 `kakao_flutter_sdk_common`을 import한다. 하지만 이 패키지는 `pubspec.yaml`에 직접 들어가 있지 않다. 그래서 import하면 `depend_on_referenced_packages` 린트 경고가 난다.
위 패키지들은 `kakao_flutter_sdk_common`을 다시 export하므로 `KakaoSdk`를 그대로 쓸 수 있다.

### main() 수정

`runApp()` 전에 초기화해야 한다. 기존 `main()`의 다른 코드(Firebase 초기화 등)는 그대로 둔다.

```dart
void main() async {
  // 웹 환경에서 카카오 로그인을 정상적으로 완료하려면 runApp() 호출 전 필요
  WidgetsFlutterBinding.ensureInitialized();

  // runApp() 호출 전 카카오 SDK 초기화
  await KakaoSdk.init(
    nativeAppKey: '${NATIVE_APP_KEY}',
    // javaScriptAppKey: '${JAVASCRIPT_APP_KEY}', // 웹도 서비스할 때만
  );

  runApp(const MainApp());
}
```

- `${NATIVE_APP_KEY}` 자리에는 실제 키를 넣는다.
- 웹을 쓰지 않으면 `javaScriptAppKey` 줄은 넣지 않는다.
- 웹을 쓰지 않으면 `ensureInitialized()` 위의 "웹 환경…" 설명 주석도 넣지 않는다. 앱 상황과 맞지 않는 주석은 읽는 사람을 헷갈리게 한다. `ensureInitialized()` 호출 자체는 `runApp()` 전에 `await`를 쓰기 위해 필요하므로 항상 넣는다.

기존 `main()`에 따라 아래처럼 처리한다.
- `void main()`이 동기 함수면 `void main() async`로 바꾼다. `await`를 쓰려면 필요하다.
- `WidgetsFlutterBinding.ensureInitialized()`가 이미 있으면 다시 넣지 않는다. 대신 `KakaoSdk.init`이 그보다 뒤, `runApp()`보다 앞에 오게 한다.
- `KakaoSdk.init(`이 이미 있으면 새로 추가하지 않는다. 키 값만 확인하고, 다르면 바꾼다.
- `runApp(...)`의 인자(위젯 이름)는 프로젝트에 있는 그대로 둔다. 예시의 `MainApp`을 복사하지 않는다.
- 스타터 프로젝트면 `// TODO(카카오 2단계)` 주석 자리에 초기화 코드를 넣고 그 주석은 지운다. `// TODO(카카오 5단계)` 주석은 남겨 둔다.

### 검증

- `flutter analyze lib/main.dart`를 실행한다. 에러와 경고가 없는지 확인한다. 실패하면 원인을 고친 뒤 다시 실행한다.
- 키가 1단계 스킴과 같은지 확인한다. `grep -rn "kakao[0-9a-f]\{32\}" android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist`로 스킴의 키를 찾아 init에 넣은 키와 비교한다. 1단계를 아직 하지 않았으면 이 비교는 건너뛴다. 그리고 1단계도 필요하다고 안내한다.

## 완료 보고에 포함할 내용

- 설치한 패키지와 버전. `pubspec.yaml`에 들어간 값을 그대로 적는다.
- `main.dart`에서 바뀐 부분. 짧은 코드 조각으로 보여준다.
- 사용한 앱 키 종류. 네이티브만인지, 웹 키도 썼는지 적는다.
- 1단계 스킴과 키가 일치하는지 확인한 결과.
