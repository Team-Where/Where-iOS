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
    @Published var isRegistrationTermViewPresented: Bool = false
    @Published var isSignInViewPresented: Bool = false
    @Published private(set) var isLoginCompleted: Bool = false
    
    private let authCore: AuthentificationCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.currentUser
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] user in
                guard let user else { return }
                self?.isLoginCompleted = true
            }
            .store(in: &cancellables)
    }
}

// MARK: Interfaces
extension LoginViewModel {
    func onAppear() {
        isRegistrationTermViewPresented = false
        isSignInViewPresented = false
        isLoginCompleted = false
    }
    
    func onChange() {
        
    }
    
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
