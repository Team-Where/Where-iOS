//
//  LoginViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/26/25.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKUser
import KakaoSDKAuth
import NaverThirdPartyLogin

final class LoginViewModel: NSObject, ObservableObject {
    private let kakaoAPI: UserApi
    private let naverAPI: NaverThirdPartyLoginConnection
    
    init(
        kakaoAPI: UserApi = .shared,
        naverAPI: NaverThirdPartyLoginConnection = .getSharedInstance()
    ) {
        self.kakaoAPI = kakaoAPI
        self.naverAPI = naverAPI
        super.init()
        _configureKakaoAPI()
        _configureNaverAPI(self.naverAPI)
    }
    
    private func _configureKakaoAPI() {
        guard let key = Bundle.fetchKey(provider: .kakao) else {
            fatalError("카카오SDK 초기화 실패: 잘못된 앱키")
        }
        
        KakaoSDK.initSDK(appKey: key)
    }
    
    private func _configureNaverAPI(_ naver: NaverThirdPartyLoginConnection) {
        guard let key = Bundle.fetchKey(provider: .naver) else {
            fatalError("네이버SDK 초기화 실패: 잘못된 앱키")
        }
        
        naver.isNaverAppOauthEnable = true
        naver.isInAppOauthEnable = true
        naver.setOnlyPortraitSupportInIphone(true)
        naver.serviceUrlScheme = "where.naver.login"
        naver.consumerKey = "EM6n_yrMpySUgUsU_d4Z"
        naver.consumerSecret = key
        naver.appName = "어디"
        naver.delegate = self
    }
}

// MARK: NaverThirdPartyLoginConnectionDelegate Conformation
extension LoginViewModel: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        // TODO: 획득한 토큰을 사용해 네이버로 사용자 정보 요청 로직 구현
        guard naverAPI.isValidAccessTokenExpireTimeNow() == false else { return }
        
        guard let tokenType = naverAPI.tokenType,
              let accessToken = naverAPI.accessToken,
              let refreshToken = naverAPI.refreshToken
        else { return }
        
        // 네트워크 통신 필요...
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        // TODO: 토큰 갱신될 때 필요한 작업 구현
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        // TODO: 로그아웃 등으로 토큰이 삭제 됐을 때 필요한 작업 구현
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: (any Error)!) {
        // TODO: 필요한 에러 핸들링 구현
    }
}

// MARK: NaverSDK Related
extension LoginViewModel {
    private func _login() {
        naverAPI.requestThirdPartyLogin()
    }
}

// MARK: KakaoSDK Related
extension LoginViewModel {
    private func _login(_ token: OAuthToken?, _ error: Error?) {
        if let error = error { return }
        
        guard let _ = token else { return }
        
        kakaoAPI.me { user, error in
            if let error = error { return }
            
            let nickname = user?.kakaoAccount?.profile?.nickname
            let profileImageURL = user?.kakaoAccount?.profile?.profileImageUrl
            // 닉네임, 프로필사진 처리
        }
    }
}

// MARK: Apple Related
extension LoginViewModel {
    
}

// MARK: Common Interfaces
extension LoginViewModel {
    func handleOpenURL(_ provider: AuthentificationProvider, _ url: URL) {
        switch provider {
        case .apple:
            break
        case .kakao:
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        case .naver:
            naverAPI.receiveAccessToken(url)
        }
    }
    
    func login(with provider: AuthentificationProvider) {
        switch provider {
        case .apple:
            break
        case .kakao:
            let nonce = UUID().uuidString
            
            if UserApi.isKakaoTalkLoginAvailable() {
                kakaoAPI.loginWithKakaoTalk(nonce: nonce) { [weak self] token, error in
                    self?._login(token, error)
                }
            } else {
                kakaoAPI.loginWithKakaoAccount(nonce: nonce) { [weak self] token, error in
                    self?._login(token, error)
                }
            }
        case .naver:
            _login()
        }
    }
}
