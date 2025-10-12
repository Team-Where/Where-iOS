//
//  AuthentificationStrategyProtocol.swift
//  Where
//
//  Created by Swain Yun on 4/7/25.
//

import Foundation
import Combine
import AuthenticationServices

protocol AuthentificationStrategyProtocol: AnyObject {
    func login(provider: AuthentificationProvider) -> AnyPublisher<UserCredential, AuthentificationCoreError>
    func logout() -> AnyPublisher<Void, AuthentificationCoreError>
}

protocol URLHandlerStrategyProtocol {
    func handleOpenURL(_ url: URL)
}
