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
    func login(provider: AuthentificationProvider)
}

protocol URLHandlerStrategyProtocol: AuthentificationStrategyProtocol {
    func handleOpenURL(_ url: URL)
}
