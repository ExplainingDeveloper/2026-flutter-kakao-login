# 1단계: 프로젝트 설정 – 커스텀 URL 스킴

## 목적

사용자가 카카오톡으로 로그인하고 나면 카카오톡이 `kakao${NATIVE_APP_KEY}://oauth` 스킴으로 우리 앱을 다시 연다.
이 스킴을 Android와 iOS에 등록하지 않으면 로그인 후 앱으로 돌아오지 못한다.

제품별 host 값:
- 카카오 로그인: `oauth`
- 카카오톡 공유, 카카오톡 메시지: `kakaolink`

## 필요한 정보

- `NATIVE_APP_KEY`: SKILL.md의 "공통 정보 모으기"에서 받은 값
- **카카오톡 공유/메시지 사용 여부**: 이 단계에서 한 번 물어본다. 기본값은 "로그인만"이다.
  - 사용하면 Android에 `kakaolink` intent-filter를 추가하고, iOS 허용 목록에 `kakaolink`를 추가한다.
  - 키를 새로 받아야 하면 이 질문과 함께 AskUserQuestion 한 번으로 묻는다.

## Android

대상 파일: `android/app/src/main/AndroidManifest.xml`

`src/main` 아래의 메인 매니페스트를 고친다. `src/debug`, `src/profile`의 매니페스트가 아니다.

### A. 카카오 로그인 Activity (필수)

`<application>`의 직속 자식으로 아래 `<activity>`를 추가한다. `MainActivity`와 같은 레벨이다.
`MainActivity` 안에 넣으면 안 된다. Activity는 다른 Activity 안에 중첩될 수 없다.

```xml
        <!-- 카카오 로그인 커스텀 URL 스킴 설정 -->
        <activity
            android:name="com.kakao.sdk.flutter.auth.AuthCodeHandlerActivity"
            android:exported="true">
            <intent-filter android:label="flutter_web_auth">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <!-- 카카오 로그인 리다이렉트 URI -->
                <data android:scheme="kakao${NATIVE_APP_KEY}" android:host="oauth"/>
            </intent-filter>
        </activity>
```

`${NATIVE_APP_KEY}` 자리에는 실제 키를 넣는다. 결과는 `kakao0123abcd...` 형태가 된다. 이 문서의 모든 스니펫에 같은 규칙을 적용한다.

이미 `AuthCodeHandlerActivity`가 있으면 새로 추가하지 않는다. 대신 아래를 확인한다.
- `android:scheme`의 키가 현재 키와 같은지 확인한다. 다르면 키만 바꾼다.
- `android:exported="true"`인지 확인한다.

### B. 카카오톡 공유/메시지 (선택한 경우만)

`android:name=".MainActivity"`인 `<activity>` 안에 **새로운** `<intent-filter>`를 추가한다.

```xml
            <!-- 카카오톡 공유, 카카오톡 메시지 커스텀 URL 스킴 설정 -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:host="kakaolink" android:scheme="kakao${NATIVE_APP_KEY}" />
            </intent-filter>
```

기존의 `MAIN`/`LAUNCHER` intent-filter에 `<data>`를 합치지 않는다. 합치면 런처 필터가 망가져서 앱 아이콘이 홈 화면에서 사라질 수 있다. 꼭 별도의 `<intent-filter>`로 추가한다.

공식 문서 예시의 `MainActivity` 속성(`configChanges`, `theme` 등)을 그대로 복사하지 않는다. 프로젝트에 있는 `MainActivity`의 기존 속성은 그대로 두고 intent-filter만 추가한다.

### C. exported 속성

Android 12(API 31) 이상을 타깃으로 하는 앱에서는 intent-filter가 있는 Activity에 `android:exported="true"`가 반드시 있어야 한다. 없으면 설치할 때 에러가 난다.
- `AuthCodeHandlerActivity`: 위 스니펫에 이미 포함되어 있다.
- `MainActivity`: Flutter 템플릿에는 보통 이미 있다. 없으면 추가한다.

### D. 인터넷 권한

`<manifest>`의 직속 자식으로(`<application>` 밖, 위쪽) 인터넷 권한을 추가한다. 이미 있으면 건너뛴다.

```xml
    <uses-permission android:name="android.permission.INTERNET" />
```

Flutter 템플릿은 인터넷 권한을 `src/debug`, `src/profile` 매니페스트에만 넣는다. 카카오 SDK 매니페스트에도 이 권한이 없다. 그래서 이 권한을 빼면 디버그에서는 로그인이 되는데 **릴리스 빌드에서만 로그인이 실패**한다. 원인을 찾기 아주 어려운 문제라서 미리 넣는다.

### 검증

- `xmllint --noout android/app/src/main/AndroidManifest.xml`를 실행해 XML 문법을 확인한다. xmllint가 없으면 건너뛴다.
- 스킴이 정확히 들어갔는지 확인한다: `grep -n "kakao" android/app/src/main/AndroidManifest.xml`

참고: `AuthCodeHandlerActivity` 클래스는 `kakao_flutter_sdk` 패키지에 들어 있다. SDK를 아직 설치하지 않았어도 빌드는 된다. 이 Activity는 SDK를 설치한 뒤부터 실제로 동작한다.

## iOS

대상 파일: `ios/Runner/Info.plist`

iOS에는 아래 두 가지 설정이 모두 필요하다. Info.plist의 최상위 `<dict>` 안에 추가하고, 다른 키들은 건드리지 않는다. 위치는 최상위 `<dict>` 안이면 어디든 괜찮다. 닫는 `</dict>` 바로 앞에 넣으면 찾기 쉽다.

### A. 앱 실행 허용 목록 (LSApplicationQueriesSchemes)

앱이 카카오톡 설치 여부를 확인하고 카카오톡을 실행하려면 허용 목록이 필요하다.

```xml
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<!-- 카카오톡으로 로그인 -->
		<string>kakaokompassauth</string>
		<!-- 카카오톡 공유 (공유/메시지를 선택한 경우만) -->
		<string>kakaolink</string>
	</array>
```

- 이 키가 이미 있으면(다른 SDK가 추가했을 수 있음) 배열을 새로 만들지 않는다. 빠진 항목만 기존 배열에 추가한다.
- 로그인만 쓰면 `kakaokompassauth`만 넣는다.

### B. URL Schemes (CFBundleURLTypes)

카카오톡이 로그인 후 `kakao${NATIVE_APP_KEY}://`로 앱을 다시 열 수 있게 한다.

```xml
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>kakao${NATIVE_APP_KEY}</string>
			</array>
		</dict>
	</array>
```

- `CFBundleURLTypes`가 이미 있으면(구글 로그인 등) 기존 항목은 그대로 둔다. 카카오용 `<dict>`만 배열에 추가한다.
- 이미 `kakao`로 시작하는 스킴이 있으면 새로 추가하지 않는다. 키가 다르면 키만 바꾼다.

### 검증

- `plutil -lint ios/Runner/Info.plist`를 실행해 plist가 올바른지 확인한다. macOS에서만 가능하므로 없으면 건너뛴다.
- `grep -n "kakao" ios/Runner/Info.plist`

### 사용자 안내용: Xcode에서 확인하는 방법

파일을 직접 고친 결과는 Xcode에서도 볼 수 있다. 원하면 아래 경로를 알려준다.
- `ios` 폴더를 Xcode로 열기 → **TARGETS > Runner > Info**
  - **Custom iOS Target Properties**: `LSApplicationQueriesSchemes`
  - **URL Types > URL Schemes**: `kakao{앱키}`

## 완료 보고에 포함할 내용

- Android/iOS별로 추가하거나 수정한 항목. 이미 설정되어 있어 건너뛴 항목도 표시한다.
- 적용한 스킴: `kakao{앱키}://oauth` (공유를 선택했으면 `kakao{앱키}://kakaolink`도)
- 참고 정보: 카카오 디벨로퍼스 콘솔에 플랫폼을 등록할 때 필요한 값을 프로젝트에서 읽어 함께 알려준다.
  - Android 패키지명: `android/app/build.gradle(.kts)`의 `applicationId`
  - iOS 번들 ID: `ios/Runner.xcodeproj/project.pbxproj`의 Runner 타깃 `PRODUCT_BUNDLE_IDENTIFIER`. RunnerTests 값은 제외한다.
