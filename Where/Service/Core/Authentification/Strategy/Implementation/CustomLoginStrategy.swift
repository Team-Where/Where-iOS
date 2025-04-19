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
        guard case .custom(let email, _) = provider else { return }
        let credential = UserCredential(provider: provider, email: email)
        credentialSubject.send(credential)
    }
}
