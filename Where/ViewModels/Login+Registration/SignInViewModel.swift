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
    @Published private(set) var isProcessing: Bool = false
    @Published var isPopupPresented: Bool = false
    
    private let auth: any AuthentificationCoreProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(auth: any AuthentificationCoreProtocol) {
        self.auth = auth
    }
    
    private func subscribe() {
        auth.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isProcessing = false
                case .failure(let error):
                    switch error {
                    case .loginFailed, .userInfoFetchFailed:
                        self?.isProcessing = false
                        self?.isPopupPresented = true
                    case .unknown(let error):
                        #if DEBUG
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        #endif
                    default:
                        self?.isProcessing = false
                    }
                }
            } receiveValue: { user in
                #if DEBUG
                if let user = user {
                    print("자체 로그인: \(user.nickname)")
                }
                #endif
            }
            .store(in: &cancellables)
    }
}

// MARK: Interfaces
extension SignInViewModel {
    func login() {
        isProcessing = true
        auth.login(email: emailFieldText, password: passwordFieldText)
    }
}
