//
//  SignInViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import Foundation
import Combine
import Swinject

final class SignInViewModel: ObservableObject {
    @Published var emailFieldText: String = String()
    @Published var passwordFieldText: String = String()
    @Published private(set) var state: ProcessingState = .beforeLogin
    @Published var isPopupPresented: Bool = false
    var loginButtonDisabled: Bool {
        state == .processing || emailFieldText.isEmpty || passwordFieldText.isEmpty
    }
    
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
                guard user != nil else {
                    self?.state = .failure
                    return
                }
                
                self?.state = .success
            }
            .store(in: cancellableBag, key: "CurrentUser")
    }
}

// MARK: - Nested Types
extension SignInViewModel {
    /// 로그인 과정의 진행 상태
    enum ProcessingState {
        /// 로그인 하기 전
        case beforeLogin
        /// 진행 중
        case processing
        /// 로그인 성공
        case success
        /// 로그인 실패
        case failure
    }
}

// MARK: Interfaces
extension SignInViewModel {
    func onDisappear() {
        state = .beforeLogin
        emailFieldText.removeAll()
        passwordFieldText.removeAll()
    }
    
    func login() {
        state = .processing
        authCore.login(email: emailFieldText, password: passwordFieldText)
    }
}
