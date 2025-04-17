//
//  SignInViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import Foundation
import Combine

final class SignInViewModel: ObservableObject {
    @Published var emailFieldText: String = String()
    @Published var passwordFieldText: String = String()
    @Published private(set) var state: ProcessingState = .beforeLogin
    @Published var isPopupPresented: Bool = false
    var loginButtonDisabled: Bool {
        state == .processing || emailFieldText.isEmpty || passwordFieldText.isEmpty
    }
    
    private let auth: AuthentificationCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(auth: AuthentificationCoreProtocol) {
        self.auth = auth
        subscribe()
    }
    
    private func subscribe() {
        auth.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.state = .success
                case .failure(let error):
                    switch error {
                    case .loginFailed, .userInfoFetchFailed:
                        self?.state = .failure
                        self?.isPopupPresented = true
                    case .unknown(let error):
                        #if DEBUG
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        #endif
                        self?.state = .failure
                    default:
                        self?.state = .failure
                    }
                }
            } receiveValue: { [weak self] user in
                #if DEBUG
                print("자체 로그인: \(user?.nickname ?? "알 수 없음")")
                #endif
                self?.state = .success
            }
            .store(in: &cancellables)
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
        auth.login(email: emailFieldText, password: passwordFieldText)
    }
}
