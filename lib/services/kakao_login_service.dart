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

  /// 로그인한 사용자의 카카오 정보를 가져온다.
  ///
  /// 동의받지 않은 정보(닉네임, 프로필 사진 등)는 null로 온다.
  Future<User> getUser() => UserApi.instance.me();

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

  bool _isCanceled(Object error) =>
      error is PlatformException && error.code == 'CANCELED';
}
