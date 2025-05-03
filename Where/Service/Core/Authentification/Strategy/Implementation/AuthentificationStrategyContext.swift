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
    
    private func cache(by provider: AuthentificationProvider) {
        guard strategies[provider] == nil else { return }
        
        switch provider {
        case .apple: strategies[provider] = AppleLoginStrategy()
        case .kakao: strategies[provider] = KakaoLoginStrategy()
        case .naver: strategies[provider] = NaverLoginStrategy()
        default: break
        }
    }
    
    func login(by provider: AuthentificationProvider, completion: @escaping (Result<UserCredential, AuthentificationCoreError>) -> Void) {
        currentProvider = provider
        cache(by: provider)
        
        guard let strategy = strategies[provider] else { return }
        strategy.login(provider: provider, completion: completion)
    }
    
    func handleOpenURL(_ url: URL) {
        guard let provider = currentProvider,
              let strategy = strategies[provider] as? URLHandlerStrategyProtocol
        else { return }
        strategy.handleOpenURL(url)
    }
}
