# 2026 Flutter 카카오 로그인

Flutter 앱에 **카카오 로그인**을 단계별로 붙여 보는 프로젝트예요.
AI 코딩 에이전트용 **스킬**(`kakao-login-flutter`)이 함께 들어 있어서, 에이전트에게 단계 번호만 말하면 설정과 코드를 대신 작성해 줘요.

- 카카오톡으로 로그인 (카카오톡 앱)
- 카카오계정으로 로그인 (브라우저)
- 사용자 정보, 자동 로그인, 로그아웃, 회원 탈퇴

## 브랜치

| 브랜치 | 내용 | 언제 |
|---|---|---|
| `main` | **시작 상태.** 카카오 기능 없이 기본 화면만 있어요. | 영상을 따라 처음부터 해볼 때 |
| `completed` | **완성본.** 0~6단계를 모두 적용한 코드예요. | 막혔을 때 내 코드와 비교할 때 |

## 시작하기

준비물: Flutter 3.38.0 이상 (카카오 Flutter SDK v2 최소 버전), 카카오 계정

```bash
git clone https://github.com/ExplainingDeveloper/2026-flutter-kakao-login.git
cd 2026-flutter-kakao-login
flutter pub get
```

`main` 브랜치는 로그인 화면과 홈 화면의 기본 UI만 있어요. 카카오 기능이 들어갈 자리에는 `// TODO(카카오 N단계)` 표시가 있고, 스킬이 단계마다 이 자리를 채워요.

```
lib/
├── main.dart                 # TODO 2단계(SDK 초기화), 5단계(자동 로그인)
└── screens/
    ├── login_screen.dart     # TODO 3단계(로그인 버튼), 4단계(홈으로 이동)
    └── home_screen.dart      # TODO 4단계(사용자 정보), 6단계(로그아웃·탈퇴)
```

### 완성본을 실행해 보려면

```bash
git switch completed
flutter pub get
```

`completed` 브랜치의 앱 키는 `YOUR_NATIVE_APP_KEY`로 비워 뒀어요. 실행 전에 **내 네이티브 앱 키**로 세 군데를 똑같이 바꿔 주세요. 하나라도 다르면 로그인한 뒤 앱으로 돌아오지 못해요.

- `android/app/src/main/AndroidManifest.xml`: `kakaoYOUR_NATIVE_APP_KEY`
- `ios/Runner/Info.plist`: `kakaoYOUR_NATIVE_APP_KEY`
- `lib/main.dart`: `nativeAppKey: 'YOUR_NATIVE_APP_KEY'`

카카오 디벨로퍼스 콘솔 설정(0단계)도 내 앱으로 해 둬야 해요.

## 단계

| 단계 | 내용 | 누가 |
|---|---|---|
| 0 | 카카오 디벨로퍼스 앱 만들기, 플랫폼 등록(패키지명·키 해시·번들 ID), 카카오 로그인 활성화, 동의항목, 로그인 버튼 이미지 받기 | 직접 (스킬이 값 계산·안내) |
| 1 | 커스텀 URL 스킴 설정 (AndroidManifest.xml, Info.plist), 인터넷 권한 | 스킬 |
| 2 | SDK 설치(`kakao_flutter_sdk_user`)와 초기화(`KakaoSdk.init`) | 스킬 |
| 3 | 로그인 로직 (카카오톡 → 실패 시 카카오계정), 로그인 버튼 | 스킬 |
| 4 | 사용자 정보 가져오기 (프로필 사진, 닉네임, 회원번호) | 스킬 |
| 5 | 자동 로그인 (토큰 확인) | 스킬 |
| 6 | 로그아웃 / 회원 탈퇴 (연결 끊기) | 스킬 |

로그인 버튼 이미지는 [카카오 로그인 리소스 페이지](https://developers.kakao.com/tool/resource/login)에서 받아요.

## 스킬 사용법

같은 스킬이 두 곳에 들어 있어요. 내용은 똑같아요.

- [`.claude/skills/kakao-login-flutter/`](.claude/skills/kakao-login-flutter/): Claude Code용
- [`.github/skills/kakao-login-flutter/`](.github/skills/kakao-login-flutter/): GitHub Copilot용

스킬을 고칠 때는 두 폴더를 같이 고쳐 주세요.

### Claude Code

이 프로젝트를 열면 바로 쓸 수 있어요.

```
/kakao-login-flutter          # 단계 선택 메뉴
/kakao-login-flutter 0        # 0단계만
/kakao-login-flutter 1-3      # 1~3단계
/kakao-login-flutter 전체      # 0~6단계 전부
```

"카카오 로그인 2단계 해줘"처럼 말로 해도 돼요.

### GitHub Copilot (VS Code)

이 프로젝트를 열면 바로 쓸 수 있어요. 채팅창에 `/`를 입력하고 목록에서 `kakao-login-flutter`를 고르거나, "카카오 로그인 2단계 해줘"처럼 말하면 돼요.

## 스킬만 내 프로젝트에 넣기

이 레포를 받지 않고 스킬만 쓰고 싶다면 `kakao-login-flutter` 폴더 하나만 받으면 돼요. `SKILL.md`와 단계별 지침(`references/`)이 이 안에 다 들어 있어요.

### 어디에 넣나요

**Claude Code**
- 이 프로젝트에서만: `.claude/skills/`
- 내 컴퓨터 모든 프로젝트: `~/.claude/skills/`

**GitHub Copilot (VS Code)**
- 프로젝트: `.github/skills/` · `.claude/skills/` · `.agents/skills/`
- 내 컴퓨터 전체: `~/.copilot/skills/`

두 도구를 다 쓴다면 `.claude/skills/`에 넣으세요. Claude Code와 Copilot 둘 다 읽어요. `.agents/skills/`는 Copilot만 읽어요.

### 받는 방법

**터미널 (macOS · Linux)**: 내 Flutter 프로젝트 폴더에서 실행하세요.

```bash
# Claude Code (또는 둘 다 쓸 때)
mkdir -p .claude/skills && curl -sL https://github.com/ExplainingDeveloper/2026-flutter-kakao-login/archive/refs/heads/main.tar.gz | tar -xz -C .claude/skills --strip-components=3 "2026-flutter-kakao-login-main/.claude/skills/kakao-login-flutter"

# GitHub Copilot
mkdir -p .github/skills && curl -sL https://github.com/ExplainingDeveloper/2026-flutter-kakao-login/archive/refs/heads/main.tar.gz | tar -xz -C .github/skills --strip-components=3 "2026-flutter-kakao-login-main/.claude/skills/kakao-login-flutter"
```

**ZIP (Windows 포함 모든 OS)**

1. [ZIP 다운로드](https://github.com/ExplainingDeveloper/2026-flutter-kakao-login/archive/refs/heads/main.zip)
2. 압축 풀기
3. `.claude/skills/kakao-login-flutter` 폴더를 통째로 위 위치에 복사

macOS Finder에서는 `.claude`처럼 점으로 시작하는 폴더가 숨겨져 있어요. `Cmd + Shift + .`를 누르면 보여요.

### 내 프로젝트에서 돌리면

- 내 화면 파일은 건드리지 않아요. 로그인 기능(서비스)과 로그인 버튼만 만들어요.
- 내 화면에 붙이는 코드 예시는 완료 보고에 적어 줘요.
- `main.dart`가 Flutter 기본 템플릿(카운터 예제) 그대로면, 그 자리에 버튼을 넣어 바로 확인할 수 있게 해 줘요.
- `android/`나 `ios/` 폴더가 없으면 그 플랫폼 작업은 건너뛰어요.

## 참고 문서

- [카카오 로그인 Flutter 가이드](https://developers.kakao.com/docs/ko/kakaologin/flutter)
- [Flutter SDK 시작하기](https://developers.kakao.com/docs/ko/flutter/getting-started)
- [Flutter SDK v2 마이그레이션](https://developers.kakao.com/docs/ko/flutter/migration-v2)
- [카카오 로그인 디자인 가이드](https://developers.kakao.com/docs/ko/kakaologin/design-guide)
- [로그인 버튼 리소스 다운로드](https://developers.kakao.com/tool/resource/login)
- [Claude Code 스킬](https://code.claude.com/docs/en/skills)
- [VS Code Copilot 스킬](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
