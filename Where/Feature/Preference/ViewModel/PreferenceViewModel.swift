//
//  PreferenceViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/29/25.
//

import Foundation
import Swinject
import Combine

final class PreferenceViewModel: ObservableObject {
    private let authCore: AuthentificationCoreProtocol
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
    }
}

// MARK: - Interfaces
extension PreferenceViewModel {
    func logout() {
        authCore.logout()
    }
}
