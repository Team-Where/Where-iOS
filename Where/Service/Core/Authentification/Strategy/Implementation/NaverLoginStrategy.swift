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
    private let naverAPI: NaverLoginPublishable = NidOAuth.shared
    
    override init() {
        super.init()
        naverAPI.configure()
    }
    
}

// MARK: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol Confirmation
extension NaverLoginStrategy: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol {

    func login(provider: AuthentificationProvider) -> AnyPublisher<UserCredential, AuthentificationCoreError> {
        guard case .naver = provider
        else {
            return Fail(error: .notSupported)
                .eraseToAnyPublisher()
        }
        return naverAPI.loginPubilsher()
            .map {
                UserCredential(accessToken: $0.accessToken.tokenString, refreshToken: $0.refreshToken.tokenString)
            }
            .mapError { _ in
                AuthentificationCoreError.socialAuthProviderAuthorizationFailed
            }
            .eraseToAnyPublisher()
        
    }
    
    func logout() -> AnyPublisher<Void, AuthentificationCoreError> {
        return Just(NidOAuth.shared.logout())
            .setFailureType(to: AuthentificationCoreError.self)
            .eraseToAnyPublisher()
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
    func configure() {
        NidOAuth.shared.initialize()
        NidOAuth.shared.setLoginBehavior(.appPreferredWithInAppBrowserFallback)
    }
    
    
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
