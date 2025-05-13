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
        container.register(JSONDecoder.self) { _ in
            JSONDecoder()
        }
        .inObjectScope(.container)
        
        container.register(JSONEncoder.self) { _ in
            JSONEncoder()
        }
        .inObjectScope(.container)
        
        container.register(TokenStorageProtocol.self) { resolver in
            guard let encoder = resolver.resolve(JSONEncoder.self),
                  let decoder = resolver.resolve(JSONDecoder.self)
            else {
                fatalError("Failed Initializing TokenStorage")
                
            }
            return TokenStorage(encoder, decoder)
        }
        .inObjectScope(.container)
        
        
        container.register(APIServable.self) { resolver in
            guard let decoder = resolver.resolve(JSONDecoder.self),
                  let encoder = resolver.resolve(JSONEncoder.self),
                  let tokenStorage = resolver.resolve(TokenStorageProtocol.self)
            else {
                fatalError("Failed Initializing APIService")
            }
            return APIService(decoder, encoder, tokenStorage)
        }
        .inObjectScope(.container)
        
        container.register(KakaoShareServiceProtocol.self) { _ in
            KakaoShareService()
        }
    }
}
