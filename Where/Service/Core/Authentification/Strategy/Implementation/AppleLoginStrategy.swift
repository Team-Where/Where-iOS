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
    
}

// MARK: - AppleLoginStrategyProtocol Confirmation
extension AppleLoginStrategy: AuthentificationStrategyProtocol {
    func login(provider: AuthentificationProvider) -> AnyPublisher<UserCredential, AuthentificationCoreError> {
        guard case .apple(let auth) = provider else {
            return Fail(error: .notSupported)
                .eraseToAnyPublisher()
        }
        switch auth.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let code = appleIDCredential.authorizationCode
            let credential = UserCredential(authorizationCode: code)
            return Just(credential)
                .setFailureType(to: AuthentificationCoreError.self)
                .eraseToAnyPublisher()
        default:
            return Fail(error: .socialAuthProviderAuthorizationFailed)
                .eraseToAnyPublisher()
        }
    }
    
    func logout() -> AnyPublisher<Void, AuthentificationCoreError> {
        Empty(outputType: Void.self, failureType: AuthentificationCoreError.self).eraseToAnyPublisher()
    }
}
