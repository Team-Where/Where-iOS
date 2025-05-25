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
    
    private func handleKakaoLoginResult(token: OAuthToken?, error: Error?) throws(AuthentificationCoreError) -> UserCredential {
        if let _ = error {
            throw .socialAuthProviderAuthorizationFailed
        }
        
        guard let token = token else {
            throw .socialAuthProviderAuthorizationFailed
        }
        
        return UserCredential(accessToken: token.accessToken, refreshToken: token.refreshToken)
    }
}

// MARK: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol Confirmation
extension KakaoLoginStrategy: AuthentificationStrategyProtocol, @preconcurrency URLHandlerStrategyProtocol {
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
    
    @MainActor func handleOpenURL(_ url: URL) {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            _ = AuthController.handleOpenUrl(url: url)
        }
    }
}

// MARK: - KakaoLogin with Combine

protocol KakaoLoginPublishable {
    func loginPublisher(nonce: String) -> AnyPublisher<OAuthToken?, Error>
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
}
