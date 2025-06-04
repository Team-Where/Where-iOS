//
//  SignInViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class SignInViewModel {
    private(set) var state: ProcessingState = .beforeLogin
    
    private let authCore: AuthentificationCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
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
        case fail
    }
}

// MARK: Interfaces
extension SignInViewModel {
    func login(email: String, password: String) {
        state = .processing
        authCore.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.state = .success
                case .failure:
                    self?.state = .fail
                }
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
    }
}
