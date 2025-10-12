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
    private let kakaoAPI: KakaoLoginPublishable = UserApi.shared
    
    private func handleKakaoLoginResult(token: OAuthToken?) throws(AuthentificationCoreError) -> UserCredential {
        guard let token = token
        else {
            throw .socialAuthProviderAuthorizationFailed
        }
        
        return UserCredential(accessToken: token.accessToken, refreshToken: token.refreshToken)
    }
}

// MARK: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol Confirmation
extension KakaoLoginStrategy: AuthentificationStrategyProtocol, @preconcurrency URLHandlerStrategyProtocol{
    
    func login(provider: AuthentificationProvider) -> AnyPublisher<UserCredential, AuthentificationCoreError> {
        guard case .kakao = provider
        else {
            return Fail(error: .notSupported)
                .eraseToAnyPublisher()
        }
        
        let nonce = UUID().uuidString
        
        return kakaoAPI.loginPublisher(nonce: nonce)
            .tryCompactMap { [weak self] token in
                try self?.handleKakaoLoginResult(token: token)
            }
            .mapError { _ in
                AuthentificationCoreError.socialAuthProviderAuthorizationFailed
            }
            .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, AuthentificationCoreError> {
        return kakaoAPI.logoutPublisher()
            .mapError { _ in
                AuthentificationCoreError.logoutFailed
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor func handleOpenURL(_ url: URL) {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            _ = AuthController.handleOpenUrl(url: url)
        }
    }
}

// MARK: - KakaoLogin with Combine

protocol KakaoLoginPublishable {
    func loginPublisher(nonce: String) -> AnyPublisher<OAuthToken?, Error>
    func logoutPublisher() -> AnyPublisher<Void, Error>
}

extension UserApi: KakaoLoginPublishable {
    func loginPublisher(nonce: String) -> AnyPublisher<OAuthToken?, Error> {
        return Future<OAuthToken?, Error> { [weak self] promise in
            
            if UserApi.isKakaoTalkLoginAvailable() {
                self?.loginWithKakaoTalk(nonce: nonce) { token, error in
                    if let error = error {
                        return promise(.failure(error))
                    }
                    return promise(.success(token))
                }
            } else {
                self?.loginWithKakaoAccount(nonce: nonce) { token, error in
                    if let error = error {
                        return promise(.failure(error))
                    }
                    return promise(.success(token))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func logoutPublisher() -> AnyPublisher<Void, any Error> {
        return Future<Void, Error> { promise in
            UserApi.shared.logout { error in
                guard let error else { return promise(.success(())) }
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
