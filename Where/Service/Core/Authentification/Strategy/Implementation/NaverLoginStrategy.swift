//
//  NaverLoginStrategy.swift
//  Where
//
//  Created by Swain Yun on 4/7/25.
//

import Foundation
import Combine
import NidThirdPartyLogin

final class NaverLoginStrategy: NSObject {
    private let naverAPI: NidOAuth = .shared
    
    override init() {
        super.init()
        _configureNaverAPI(naverAPI)
    }
    
    private func _configureNaverAPI(_ naver: NidOAuth) {
        naver.initialize()
        naver.setLoginBehavior(.appPreferredWithInAppBrowserFallback)
    }
    
    private func handleNaverLoginResult(_ result: Result<LoginResult, NidError>) throws(AuthentificationCoreError) -> UserCredential {
        switch result {
        case .success(let tokens):
            let accessToken = tokens.accessToken.tokenString
            let refreshToken = tokens.refreshToken.tokenString
            return UserCredential(accessToken: accessToken, refreshToken: refreshToken)
        case .failure:
            throw .socialAuthProviderAuthorizationFailed
        }
    }
}

// MARK: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol Confirmation
extension NaverLoginStrategy: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol {
    func login(provider: AuthentificationProvider, completion: @escaping (Result<UserCredential, AuthentificationCoreError>) -> Void) {
        guard case .naver = provider else { return completion(.failure(.notSupported)) }
        
        naverAPI.requestLogin { [weak self] result in
            guard let credential = try? self?.handleNaverLoginResult(result) else {
                return completion(.failure(.socialAuthProviderAuthorizationFailed))
            }
            return completion(.success(credential))
        }
    }
    
    func handleOpenURL(_ url: URL) {
        _ = naverAPI.handleURL(url)
    }
    
}

// MARK: - NaverLogin with Combine

protocol NaverLoginPublishable {
    func loginPubilsher() -> AnyPublisher<LoginResult, NidError>
}

extension NaverLoginPublishable {
    func handleURL(_ url: URL) {
        _ = NidOAuth.shared.handleURL(url)
    }
}
extension NidOAuth: NaverLoginPublishable {
    func loginPubilsher() -> AnyPublisher<LoginResult, NidError> {
        return Future<LoginResult, NidError> { [weak self] promise in
            self?.requestLogin { result in
                switch result {
                case .success(let result):
                    return promise(.success(result))
                case .failure(let error):
                    return promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
