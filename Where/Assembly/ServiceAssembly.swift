//
//  ServiceAssembly.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import Foundation
import Swinject

struct ServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NetworkServiceProtocol.self) { _ in
            NetworkService()
        }
        container.register(TokenStorageProtocol.self) { _ in
            TokenStorage()
        }
    }
}
