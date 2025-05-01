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
    private let credentialSubject: PassthroughSubject<UserCredential, AuthentificationCoreError>
    
    init(credentialSubject: PassthroughSubject<UserCredential, AuthentificationCoreError>) {
        self.credentialSubject = credentialSubject
    }
}

// MARK: - AppleLoginStrategyProtocol Confirmation
extension AppleLoginStrategy: AuthentificationStrategyProtocol {
    func login(provider: AuthentificationProvider) {
        guard case .apple(let auth) = provider else { return }

        switch auth.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let code = appleIDCredential.authorizationCode
            let userCredential = UserCredential(authorizationCode: code)
            credentialSubject.send(userCredential)
            
        default:
            credentialSubject.send(completion: .failure(.notSupported))
        }
    }
}
