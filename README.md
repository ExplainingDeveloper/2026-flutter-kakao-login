# 2026 Flutter 카카오 로그인

Flutter 앱에 **카카오 로그인**을 단계별로 붙여 보는 프로젝트예요.
AI 코딩 에이전트용 **스킬**(`kakao-login-flutter`)이 함께 들어 있어서, 에이전트에게 단계 번호만 말하면 설정과 코드를 대신 작성해 줘요.

- 카카오톡으로 로그인 (카카오톡 앱)
- 카카오계정으로 로그인 (브라우저)
- 사용자 정보, 자동 로그인, 로그아웃, 회원 탈퇴

## 시작하기

```bash
git clone https://github.com/ExplainingDeveloper/2026-flutter-kakao-login.git
cd 2026-flutter-kakao-login
flutter pub get
```

`main` 브랜치는 **카카오 기능이 없는 시작 상태**예요. 로그인 화면과 홈 화면의 기본 UI만 있고, 카카오 기능이 들어갈 자리에는 `// TODO(카카오 N단계)` 표시가 있어요. 스킬이 단계마다 이 자리를 채워요.

```
lib/
├── main.dart                 # TODO 2단계(SDK 초기화), 5단계(자동 로그인)
└── screens/
    ├── login_screen.dart     # TODO 3단계(로그인 버튼), 4단계(홈으로 이동)
    └── home_screen.dart      # TODO 4단계(사용자 정보), 6단계(로그아웃·탈퇴)
```

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

이 프로젝트를 열면 바로 쓸 수 있어요. Copilot 채팅을 에이전트 모드로 두고 `/kakao-login-flutter`를 입력하거나, "카카오 로그인 2단계 해줘"처럼 말하면 돼요.

### 다른 에이전트

`SKILL.md` 형식은 여러 에이전트가 지원하는 공개 표준(Agent Skills)이에요. 쓰는 도구의 스킬 폴더에 `kakao-login-flutter` 폴더를 복사하세요.

| 도구 | 넣을 위치 (예시) |
|---|---|
| Claude Code | `프로젝트/.claude/skills/` 또는 `~/.claude/skills/` (모든 프로젝트) |
| GitHub Copilot (VS Code) | `프로젝트/.github/skills/` |
| 그 외 | 도구의 스킬 폴더 |

폴더 위치는 도구 버전마다 바뀔 수 있으니, 쓰는 도구의 문서에서 한 번 확인해 주세요.
스킬을 지원하지 않는 도구라면 `SKILL.md`와 `references/step-NN-*.md` 내용을 지침으로 붙여 넣어 써도 돼요.

### 내 프로젝트에 쓰기

이 스타터가 아닌 내 앱에도 쓸 수 있어요. 스킬 폴더를 내 프로젝트(또는 홈 폴더)의 스킬 위치에 복사하면 돼요.
이 경우 스킬은 **화면을 건드리지 않아요.** 로그인 기능 코드와 버튼만 만들고, 내 화면에 붙이는 방법을 알려줘요.

## 참고 문서

- [카카오 로그인 Flutter 가이드](https://developers.kakao.com/docs/ko/kakaologin/flutter)
- [Flutter SDK 시작하기](https://developers.kakao.com/docs/ko/flutter/getting-started)
- [카카오 로그인 디자인 가이드](https://developers.kakao.com/docs/ko/kakaologin/design-guide)
- [로그인 버튼 리소스 다운로드](https://developers.kakao.com/tool/resource/login)
