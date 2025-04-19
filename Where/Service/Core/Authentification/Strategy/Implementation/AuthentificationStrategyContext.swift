//
//  AuthentificationStrategyContext.swift
//  Where
//
//  Created by Swain Yun on 4/7/25.
//

import Foundation
import Combine

final class AuthentificationStrategyContext {
    private var strategies = [AuthentificationProvider: AuthentificationStrategyProtocol]()
    private var currentProvider: AuthentificationProvider?
    
    let credentialSubject = PassthroughSubject<UserCredential, AuthentificationCoreError>()
    
    private func cache(by provider: AuthentificationProvider) {
        guard strategies[provider] == nil else { return }
        
        switch provider {
        case .apple: strategies[provider] = AppleLoginStrategy(credentialSubject: credentialSubject)
        case .kakao: strategies[provider] = KakaoLoginStrategy(credentialSubject: credentialSubject)
        case .naver: strategies[provider] = NaverLoginStrategy(credentialSubject: credentialSubject)
        case .custom: strategies[provider] = CustomLoginStrategy(credentialSubject: credentialSubject)
        }
    }
    
    func login(by provider: AuthentificationProvider) {
        currentProvider = provider
        cache(by: provider)
        
        guard let strategy = strategies[provider] else { return }
        strategy.login(provider: provider)
    }
    
    func handleOpenURL(_ url: URL) {
        guard let provider = currentProvider,
              let strategy = strategies[provider] as? URLHandlerStrategyProtocol
        else { return }
        strategy.handleOpenURL(url)
    }
}
