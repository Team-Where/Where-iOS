//
//  AuthAssembly.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import Foundation
import Swinject

struct CoreAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(AuthentificationCoreProtocol.self) { resolver in
            guard let networkService = resolver.resolve(NetworkServiceProtocol.self),
                  let tokenStorage = resolver.resolve(TokenStorageProtocol.self)
            else {
                fatalError("NetworkServiceProtocol and TokenStorageProtocol not registered")
            }
            return AuthentificationCore(networkService: networkService, tokenStorage: tokenStorage)
        }
        container.register(CommunityCoreProtocol.self) { resolver in
            guard let networkService = resolver.resolve(NetworkServiceProtocol.self),
                  let tokenStorage = resolver.resolve(TokenStorageProtocol.self),
                  let auth = resolver.resolve(AuthentificationCoreProtocol.self)
            else {
                fatalError("NetworkServiceProtocol, TokenStorageProtocol and AuthentificationCoreProtocol not registered")
            }
            return CommunityCore(networkService: networkService, tokenStorage: tokenStorage, auth: auth)
        }
        container.register(MeetingCoreProtocol.self) { resolver in
            guard let authCore = resolver.resolve(AuthentificationCoreProtocol.self)
            else {
                fatalError("AuthentificationCoreProtocol not registered")
            }
            return MeetingCore(authCore: authCore)
        }
    }
}
