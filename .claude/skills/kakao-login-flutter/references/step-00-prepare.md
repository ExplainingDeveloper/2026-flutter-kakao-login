# 0단계: 준비 – 카카오 디벨로퍼스 설정과 로그인 버튼 이미지

## 목적

코드 작업(1~3단계) 전에 사용자가 직접 해야 하는 일을 안내한다.
- 카카오 디벨로퍼스 콘솔 설정
- 공식 로그인 버튼 이미지 받기

이 단계에서는 주로 안내를 한다. 스킬이 대신할 수 있는 일은 직접 해서 사용자가 값을 복사해 붙여넣기만 하면 되게 만든다.
- 프로젝트에서 패키지명과 번들 ID 읽기
- 디버그 키 해시 계산하기
- 이미지 폴더 만들기

콘솔 설정을 빠뜨리면 코드가 맞아도 로그인이 실패한다. 그러면 원인을 찾기 어렵기 때문에 맨 앞에서 챙긴다.

## A. 값 미리 준비하기 (스킬이 직접)

안내문에 넣을 값을 프로젝트에서 읽거나 계산한다.

1. **Android 패키지명**: `android/app/build.gradle.kts`(또는 `build.gradle`)의 `applicationId`
2. **iOS 번들 ID**: `ios/Runner.xcodeproj/project.pbxproj`에서 Runner 타깃의 `PRODUCT_BUNDLE_IDENTIFIER`. `RunnerTests`로 끝나는 값은 제외한다.
3. **디버그 키 해시**: 아래 명령으로 계산한다.
   ```bash
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore \
     -storepass android -keypass android | openssl sha1 -binary | openssl base64
   ```
   - `keytool`이 PATH에 없으면 Android Studio에 들어 있는 JDK를 쓴다.
     - macOS: `/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool`
   - `~/.android/debug.keystore`가 없으면(Android 빌드를 한 번도 하지 않은 경우) 계산을 건너뛴다. 대신 "Android로 한 번 `flutter run` 한 뒤 다시 실행하거나, 3단계 이후 앱에서 `KakaoSdk.origin`으로 확인할 수 있다"고 안내한다.
   - 결과는 `xxxxxxxxxxxxxxxxxxxxxxxxxxx=`처럼 28자 정도의 Base64 문자열이다.
   - 결과가 `2jmj7l5rSw0yVb/vlWAYkK/YBwk=`이면 실패한 것이다. keytool이 실패해서 빈 입력의 해시가 나온 것이므로 사용자에게 보여주지 않는다. keytool의 에러 메시지를 확인하고, 계산에 실패했다고 안내한다.
   - keytool이 `SHA1withRSA ... security risk` 경고를 출력해도 무시한다. 디버그 키에서는 정상이다.

패키지명이나 번들 ID가 `com.example.`로 시작하면 한 줄로 알려준다. 출시 전에 바꾸는 경우가 많고, 바꾸면 콘솔에도 다시 등록해야 한다.

## B. 콘솔 설정 안내

A에서 구한 값을 채워 넣어 아래 체크리스트를 한국어로 보여준다. 메뉴 경로와 링크는 그대로 둔다.

1. **애플리케이션 만들기**
   - https://developers.kakao.com/console/app 에서 [애플리케이션 추가하기]를 누른다.
   - 앱 이름과 회사명을 입력한다.
2. **네이티브 앱 키 확인**
   - [앱] > [플랫폼 키] > **네이티브 앱 키**를 복사해 둔다.
   - 1, 2단계에서 이 키를 입력하게 된다. REST API 키나 JavaScript 키가 아니다.
3. **플랫폼 등록**
   - 경로: [앱] > [플랫폼] (참고: https://developers.kakao.com/docs/ko/app-setting/app#key)
   - Android
     - 패키지명: `<A-1 값>`
     - 키 해시: `<A-3 값>`
     - 이 키 해시는 디버그용이다. 릴리스 빌드나 Play 스토어 배포 시에는 릴리스 키 해시도 추가로 등록해야 한다.
   - iOS
     - 번들 ID: `<A-2 값>`
4. **카카오 로그인 활성화**
   - [카카오 로그인] > 활성화 설정 **ON**
   - 참고: https://developers.kakao.com/docs/ko/kakaologin/prerequisite#kakao-login-activate
5. **동의항목 설정**
   - [카카오 로그인] > [동의항목]에서 받을 정보를 설정한다. 예: 닉네임, 프로필 사진
   - 참고: https://developers.kakao.com/docs/ko/kakaologin/prerequisite#scope-setting

리다이렉트 URI 등록은 웹 서비스용이다. 이 스킬은 모바일 앱만 다루므로 안내하지 않는다.

## C. 로그인 버튼 이미지 받기

공식 리소스 페이지는 다운로드 링크를 직접 노출하지 않는다. 그래서 스킬이 이미지를 자동으로 받을 수 없고, 사용자가 직접 받아야 한다.

1. 스킬이 프로젝트 루트에 `assets/images/kakao/` 폴더를 만든다. 이미 있으면 그대로 둔다.
   - 폴더에 PNG가 이미 있으면 파일 목록을 보여준다. 아래 받는 방법은 "다른 버튼으로 바꾸고 싶을 때"로 안내한다.
2. 사용자에게 아래 순서를 안내한다.
   - https://developers.kakao.com/tool/resource/login 을 연다. 메뉴로는 [도구] > [리소스 다운로드] > [카카오 로그인]이다.
   - 원하는 버튼을 받는다.
     - **완성형**: 노란 바탕에 말풍선 심볼과 "카카오 로그인" 글자가 있는 기본형
     - **축약형**: "로그인"만 있는 작은 버튼
     - 한국어 서비스라면 **완성형 한국어**를 추천한다.
   - ZIP으로 받았다면 압축을 풀고 **PNG 파일**만 `assets/images/kakao/`에 넣는다. PSD는 편집용 원본이라 앱에 넣지 않는다.
   - 같은 이미지가 여러 해상도로 있으면 가장 큰 것 하나만 넣어도 된다.
3. 디자인 가이드의 핵심도 한 줄로 알려준다. 이미지를 늘리거나 색을 바꾸면 안 되고, 비율을 유지한 채 크기만 조절해야 한다. (https://developers.kakao.com/docs/ko/kakaologin/design-guide)

`pubspec.yaml`에 에셋을 등록하고 버튼에 연결하는 일은 3단계에서 한다.

## D. 진행 확인

- **0단계만 실행한 경우**: 체크리스트를 보여주고 끝낸다. 다음 단계는 1단계라고 알린다.
- **"전체"로 실행한 경우**: 콘솔 설정은 사용자가 브라우저에서 해야 하므로 AskUserQuestion으로 잠시 기다린다.
  - 질문 예: "카카오 디벨로퍼스 설정과 버튼 이미지 준비를 마치셨나요?"
  - 선택지:
    - `완료했어요` → 1단계로 넘어간다.
    - `코드 작업 먼저 할게요` → 그대로 1단계로 넘어간다. 완료 보고에 남은 콘솔 작업을 다시 적는다.
  - 코드 작업은 콘솔 설정이 없어도 진행할 수 있다. 그래서 설정을 마치지 않았어도 막지 않는다.
  - 1단계에서 네이티브 앱 키를 물어볼 때 "방금 콘솔에서 복사한 네이티브 앱 키"라고 이어서 안내한다.

## 완료 보고에 포함할 내용

- 채워진 체크리스트: 패키지명, 번들 ID, 키 해시 값 포함
- 만든 이미지 폴더 경로
- 키 해시 계산에 실패했으면 그 이유와 대안
