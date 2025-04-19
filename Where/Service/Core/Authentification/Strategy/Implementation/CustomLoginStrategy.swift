//
//  CustomLoginStrategy.swift
//  Where
//
//  Created by Swain Yun on 4/19/25.
//

import Foundation
import Combine

final class CustomLoginStrategy {
    private let credentialSubject: PassthroughSubject<UserCredential, AuthentificationCoreError>
    
    init(credentialSubject: PassthroughSubject<UserCredential, AuthentificationCoreError>) {
        self.credentialSubject = credentialSubject
    }
}

// MARK: - AuthentificationStrategyProtocol Conformation
extension CustomLoginStrategy: AuthentificationStrategyProtocol {
    func login(provider: AuthentificationProvider) {
        guard case .custom(let email, let password) = provider else { return }

        // TODO: 자체 로그인 로직 구현
        // 1. 네트워크 요청
        // 2. 결과에 따라 UserCredential 또는 Error 전달
        
        // credentialSubject.send(<#T##input: UserCredential##UserCredential#>)
    }
}
