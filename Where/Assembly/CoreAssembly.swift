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
            guard let tokenStorage = resolver.resolve(TokenStorageProtocol.self)
            else {
                fatalError("TokenStorageProtocol not registered")
            }
            return AuthentificationCore(tokenStorage: tokenStorage)
        }
        container.register(CommunityCoreProtocol.self) { resolver in
            guard let tokenStorage = resolver.resolve(TokenStorageProtocol.self),
                  let auth = resolver.resolve(AuthentificationCoreProtocol.self)
            else {
                fatalError("TokenStorageProtocol and AuthentificationCoreProtocol not registered")
            }
            return CommunityCore(tokenStorage: tokenStorage, auth: auth)
        }
        container.register(MeetingCoreProtocol.self) { resolver in
            guard let authCore = resolver.resolve(AuthentificationCoreProtocol.self),
                  let tokenStorage = resolver.resolve(TokenStorageProtocol.self)
            else {
                fatalError("AuthentificationCoreProtocol, TokenStorageProtocol not registered")
            }
            return MeetingCore(authCore: authCore, tokenStorage: tokenStorage)
        }
        container.register(PlaceCoreProtocol.self) { resolver in
            guard let tokenStorage = resolver.resolve(TokenStorageProtocol.self),
                  let authCore = resolver.resolve(AuthentificationCoreProtocol.self)
            else {
                fatalError("TokenStorageProtocol, AuthentificationCoreProtocol not registered")
            }
            return PlaceCore(tokenStorage: tokenStorage, authCore: authCore)
        }
    }
}
