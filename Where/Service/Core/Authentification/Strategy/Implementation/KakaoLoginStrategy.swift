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
    
    init() {
        _configureKakaoAPI()
    }
    
    private func _configureKakaoAPI() {
        guard let key = Bundle.fetchKey(provider: .kakao) else {
            fatalError("카카오SDK 초기화 실패: 잘못된 앱키")
        }
        
        KakaoSDK.initSDK(appKey: key)
    }
    
    private func handleKakaoLoginResult(token: OAuthToken?, error: Error?) throws(AuthentificationCoreError) -> UserCredential {
        if let error = error {
            throw .socialAuthProviderAuthorizationFailed
        }
        
        guard let token = token else {
            throw .socialAuthProviderAuthorizationFailed
        }
        
        return UserCredential(accessToken: token.accessToken, refreshToken: token.refreshToken)
    }
}

// MARK: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol Confirmation
extension KakaoLoginStrategy: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol {
    func login(provider: AuthentificationProvider, completion: @escaping (Result<UserCredential, AuthentificationCoreError>) -> Void) {
        guard case .kakao = provider else { return completion(.failure(.notSupported)) }
        
        let nonce = UUID().uuidString
        
        if UserApi.isKakaoTalkLoginAvailable() {
            kakaoAPI.loginWithKakaoTalk(nonce: nonce) { [weak self] token, error in
                guard let credential = try? self?.handleKakaoLoginResult(token: token, error: error) else {
                    return completion(.failure(.socialAuthProviderAuthorizationFailed))
                }
                return completion(.success(credential))
            }
        } else {
            kakaoAPI.loginWithKakaoAccount(nonce: nonce) { [weak self] token, error in
                guard let credential = try? self?.handleKakaoLoginResult(token: token, error: error) else {
                    return completion(.failure(.socialAuthProviderAuthorizationFailed))
                }
                return completion(.success(credential))
            }
        }
    }
    
    func handleOpenURL(_ url: URL) {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            _ = AuthController.handleOpenUrl(url: url)
        }
    }
}
