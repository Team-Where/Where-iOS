//
//  KakaoLoginStrategy.swift
//  Where
//
//  Created by Swain Yun on 4/7/25.
//

import Foundation
import Combine
import KakaoSDKCommon
import KakaoSDKUser
import KakaoSDKAuth

final class KakaoLoginStrategy {
    private let kakaoAPI: UserApi = .shared
    private let credentialSubject: PassthroughSubject<UserCredential, AuthentificationCoreError>
    
    init(credentialSubject: PassthroughSubject<UserCredential, AuthentificationCoreError>) {
        self.credentialSubject = credentialSubject
        _configureKakaoAPI()
    }
    
    private func _configureKakaoAPI() {
        guard let key = Bundle.fetchKey(provider: .kakao) else {
            fatalError("카카오SDK 초기화 실패: 잘못된 앱키")
        }
        
        KakaoSDK.initSDK(appKey: key)
    }
    
    private func handleKakaoLoginResult(token: OAuthToken?, error: Error?) {
        if let error = error {
            #if DEBUG
            print("Error occured from KakaoLoginStrategy: \(error)")
            #endif
            credentialSubject.send(completion: .failure(.socialAuthProviderAuthorizationFailed))
            return
        }
        
        kakaoAPI.me { [weak self] user, error in
            // TODO: 에러 핸들링 강화 필요
            if let error = error {
                #if DEBUG
                print("Error occured from KakaoLoginStrategy: \(error)")
                #endif
                self?.credentialSubject.send(completion: .failure(.socialAuthProviderAuthorizationFailed))
                return
            }
            
            guard let userId = user?.id else {
                self?.credentialSubject.send(completion: .failure(.userInfoFetchFailed))
                return
            }
            
            let email = user?.kakaoAccount?.email
            let nickname = user?.kakaoAccount?.profile?.nickname
            
            let userCredential = UserCredential(provider: .kakao, ci: String(userId), email: email, nickname: nickname)
            
            self?.credentialSubject.send(userCredential)
        }
    }
}

// MARK: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol Confirmation
extension KakaoLoginStrategy: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol {
    func login(provider: AuthentificationProvider) {
        guard case .kakao = provider else { return }
        
        let nonce = UUID().uuidString
        
        if UserApi.isKakaoTalkLoginAvailable() {
            kakaoAPI.loginWithKakaoTalk(nonce: nonce) { [weak self] token, error in
                self?.handleKakaoLoginResult(token: token, error: error)
            }
        } else {
            kakaoAPI.loginWithKakaoAccount(nonce: nonce) { [weak self] token, error in
                self?.handleKakaoLoginResult(token: token, error: error)
            }
        }
    }
    
    func handleOpenURL(_ url: URL) {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            _ = AuthController.handleOpenUrl(url: url)
        }
    }
}
