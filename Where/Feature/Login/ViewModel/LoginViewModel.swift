//
//  LoginViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import Foundation
import AuthenticationServices
import Combine
import Swinject

@MainActor
final class LoginViewModel: ObservableObject {
    @Published private(set) var isProcessing: Bool = false
    
    private let authCore: AuthentificationCoreProtocol
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
    }
}

// MARK: Interfaces
extension LoginViewModel {
    func handleOpenURL(_ provider: AuthentificationProvider, url: URL) {
        authCore.handleOpenURL(provider, url)
    }
    
    func loginWithNaver() {
        authCore.loginWithNaver()
    }
    
    func loginWithKakao() {
        authCore.loginWithKakao()
    }
    
    func loginWithApple(auth: ASAuthorization) {
        authCore.loginWithApple(auth: auth)
    }
}
