//
//  AppleLoginStrategy.swift
//  Where
//
//  Created by Swain Yun on 4/7/25.
//

import Foundation
import Combine
import AuthenticationServices

final class AppleLoginStrategy {
    private let credentialSubject = PassthroughSubject<UserCredential, AuthentificationCoreError>()
    
    var credential: AnyPublisher<UserCredential, AuthentificationCoreError> {
        credentialSubject.eraseToAnyPublisher()
    }
}

// MARK: - AppleLoginStrategyProtocol Confirmation
extension AppleLoginStrategy: AuthentificationStrategyProtocol {
    func login(provider: AuthentificationProvider) {
        guard case .apple(let auth) = provider else { return }

        switch auth.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userId = appleIDCredential.user
            let email = appleIDCredential.email
            let nickname = appleIDCredential.fullName?.nickname
            let userCredential = UserCredential(provider: .apple(auth: auth), ci: userId, email: email, nickname: nickname)
            credentialSubject.send(userCredential)
            
        default:
            credentialSubject.send(completion: .failure(.notSupported))
        }
    }
}
