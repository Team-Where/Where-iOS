//
//  LoginViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import Foundation
import AuthenticationServices
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published private(set) var isProcessing: Bool = false
    
    private let auth: any AuthentificationCoreProtocol
    
    init(auth: any AuthentificationCoreProtocol) {
        self.auth = auth
    }
}

// MARK: Interfaces
extension LoginViewModel {
    func handleOpenURL(_ provider: AuthentificationProvider, url: URL) {
        auth.handleOpenURL(provider, url)
    }
    
    func loginWithNaver() {
        auth.loginWithNaver()
    }
    
    func loginWithKakao() {
        auth.loginWithKakao()
    }
    
    func loginWithApple(auth: ASAuthorization) {
        self.auth.loginWithApple(auth: auth)
    }
}
