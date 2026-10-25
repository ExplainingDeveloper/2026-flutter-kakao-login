# 4단계: 사용자 정보 가져오기

## 목적

로그인한 사용자의 카카오 정보(회원번호, 닉네임, 프로필 사진)를 `UserApi.instance.me()`로 가져온다.
스타터 프로젝트라면 홈 화면에 사용자 정보를 보여주고, 로그인에 성공하면 홈 화면으로 이동하게 연결한다.

받을 수 있는 정보는 0단계에서 콘솔에 설정한 **동의항목**에 따라 달라진다. 사용자가 동의하지 않았거나 동의항목에 없는 정보는 `null`로 온다.

## 사전 확인

`lib/services/kakao_login_service.dart`(3단계)가 있어야 한다. 없으면 3단계가 먼저 필요하다고 알린다.

## A. 서비스에 메서드 추가

`KakaoLoginService`에 아래 메서드를 추가한다. 이미 있으면 건너뛴다.

```dart
  /// 로그인한 사용자의 카카오 정보를 가져온다.
  ///
  /// 동의받지 않은 정보(닉네임, 프로필 사진 등)는 null로 온다.
  Future<User> getUser() => UserApi.instance.me();
```

자주 쓰는 값:

| 값 | 코드 |
|---|---|
| 회원번호 | `user.id` |
| 닉네임 | `user.kakaoAccount?.profile?.nickname` |
| 프로필 사진 | `user.kakaoAccount?.profile?.profileImageUrl` |
| 프로필 썸네일 | `user.kakaoAccount?.profile?.thumbnailImageUrl` |

## B. 화면에 연결

SKILL.md의 "화면 연결 기준"에 따라 결정한다.

### 스타터 프로젝트: 홈 화면에 사용자 정보 표시

`lib/screens/home_screen.dart`를 수정한다.

1. import를 추가한다.
   ```dart
   import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

   import '../services/kakao_login_service.dart';
   ```
2. `// TODO(카카오 4단계): 카카오 사용자 정보 불러오기` 줄을 아래로 바꾼다.
   ```dart
   late final Future<User> _userFuture = KakaoLoginService().getUser();
   ```
3. `build`의 `body:`를 `FutureBuilder`로 바꾼다. `_buildProfile`은 스타터에 이미 있으므로 그대로 쓴다.
   ```dart
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
   ```

### 스타터 프로젝트: 로그인 성공 시 홈 화면으로 이동

`lib/screens/login_screen.dart`에서 `const KakaoLoginButton(),`과 `// TODO(카카오 4단계)` 줄을 아래로 바꾸고, `import 'home_screen.dart';`를 추가한다.

```dart
              KakaoLoginButton(
                onSuccess: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                ),
              ),
```

`pushReplacement`를 쓰는 이유: 홈 화면에서 뒤로 가기를 눌렀을 때 로그인 화면으로 돌아가지 않게 한다.

### 그 외 프로젝트

화면 파일을 만들거나 고치지 않는다. 대신 아래 사용 예시를 완료 보고에 적는다.

```dart
final user = await KakaoLoginService().getUser();
final nickname = user.kakaoAccount?.profile?.nickname;
final imageUrl = user.kakaoAccount?.profile?.profileImageUrl;
```

## 검증

- `flutter analyze`를 실행한다. 에러와 경고가 없어야 한다.
- 스타터 프로젝트에서는 6단계 이후 `login_screen.dart`와 `home_screen.dart`가 서로를 import하게 된다. Dart에서는 정상이다.

## 완료 보고에 포함할 내용

- 추가한 메서드와 연결한 화면
- 화면 흐름: "로그인 화면 → (로그인 성공) → 홈 화면(프로필 사진, 닉네임, 회원번호)"
- 닉네임이나 사진이 안 나오면 콘솔 **[카카오 로그인] > [동의항목]**에서 해당 항목을 설정했는지 확인하라는 안내
- 동의항목을 나중에 추가했다면, 이미 로그인한 사용자는 연결 끊기(6단계) 후 다시 로그인해야 새 항목의 동의 화면이 뜬다는 안내
