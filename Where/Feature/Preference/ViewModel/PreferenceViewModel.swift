//
//  PreferenceViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/29/25.
//

import Foundation
import Swinject
import Combine

@MainActor
@Observable
final class PreferenceViewModel {
    private(set) var versionNotice = String()
    
    private let authCore: AuthentificationCoreProtocol
    private let supportCore: SupportCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        self.supportCore = resolver.resolve(SupportCore.self)!
        subscribe()
    }
    
    private func subscribe() {
        supportCore.latestVersion
            .sink { [weak self] notice in
                self?.versionNotice = notice
            }
            .store(in: cancellableBag, key: "LatestVersion")
    }
}

// MARK: - Interfaces
extension PreferenceViewModel {
    func logout() {
        authCore.logout()
    }
}
