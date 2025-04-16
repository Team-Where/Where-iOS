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
    private let credentialSubject: PassthroughSubject<UserCredential, AuthentificationCoreError>
    
    init(credentialSubject: PassthroughSubject<UserCredential, AuthentificationCoreError>) {
        self.credentialSubject = credentialSubject
        super.init()
        _configureNaverAPI(naverAPI)
    }
    
    private func _configureNaverAPI(_ naver: NidOAuth) {
        naver.initialize()
        naver.setLoginBehavior(.appPreferredWithInAppBrowserFallback)
    }
    
    private func handleNaverLoginResult(_ provider: AuthentificationProvider, _ result: Result<LoginResult, NidError>) {
        switch result {
        case .success(let tokens):
            guard tokens.accessToken.isExpired == false else {
                // 토큰 만료 시 재귀호출
                return login(provider: provider)
            }
            
            naverAPI.getUserProfile(accessToken: tokens.accessToken.tokenString) { [weak self] result in
                switch result {
                case .success(let entity):
                    guard let id = entity["id"] else { return }
                    let email = entity["email"]
                    let nickname = entity["nickname"]
                    let userCredential = UserCredential(provider: .naver, ci: id, email: email, nickname: nickname)
                    self?.credentialSubject.send(userCredential)
                case .failure(let error):
                    self?.credentialSubject.send(completion: .failure(.userInfoFetchFailed))
                }
            }
        case .failure(let error):
            self.credentialSubject.send(completion: .failure(.socialAuthProviderAuthorizationFailed))
        }
    }
}

// MARK: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol Confirmation
extension NaverLoginStrategy: AuthentificationStrategyProtocol, URLHandlerStrategyProtocol {
    func login(provider: AuthentificationProvider) {
        guard case .naver = provider else { return }
        
        naverAPI.requestLogin { [weak self] result in
            self?.handleNaverLoginResult(provider, result)
        }
    }
    
    func handleOpenURL(_ url: URL) {
        _ = naverAPI.handleURL(url)
    }
}
