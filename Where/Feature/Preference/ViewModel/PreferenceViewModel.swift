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
    private(set) var isLoginNeeded: Bool = false
    
    private let authCore: AuthentificationCoreProtocol
    private let supportCore: SupportCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        self.supportCore = resolver.resolve(SupportCore.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.currentUser
            .sink { [weak self] user in
                self?.isLoginNeeded = user == nil
            }
            .store(in: cancellableBag, key: "CurrentUser")
        
        supportCore.latestVersion
            .sink { [weak self] notice in
                self?.versionNotice = notice
            }
            .store(in: cancellableBag, key: "LatestVersion")
    }
}

// MARK: - Interfaces
extension PreferenceViewModel {
    func logout(onSuccess: @escaping () -> Void) {
        authCore.logout()
            .sink { completion in
                guard case .finished = completion else { return }
                onSuccess()
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
    }
}
