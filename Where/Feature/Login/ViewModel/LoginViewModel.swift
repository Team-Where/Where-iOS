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

@Observable
final class LoginViewModel {
    private(set) var isLoginCompleted: Bool = false
    
    private let authCore: AuthentificationCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard user != nil else { return }
                self?.isLoginCompleted = true
            }
            .store(in: cancellableBag, key: "CurrentUser")
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
