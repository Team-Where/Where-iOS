//
//  APIServiceProvidable.swift
//  Where
//
//  Created by BOMBSGIE on 4/12/25.
//

import Foundation
import Moya
import Alamofire

protocol APIServiceProvidable: Sendable {
    func makeProvider<T: TargetType>(_ endpoint: T.Type) -> MoyaProvider<T>
}

/// 토큰이 필요한 MoyaProvider 제공자
struct WithTokenAPIServiceProvider: APIServiceProvidable {
    private let key: UInt64
    private let tokenStorage: TokenStorageProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        key: UInt64,
        tokenStorage: TokenStorageProtocol,
        decoder: JSONDecoder,
        encoder: JSONEncoder
    ) {
        self.key = key
        self.tokenStorage = tokenStorage
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func makeProvider<T: TargetType>(_ endpoint: T.Type) -> MoyaProvider<T> {
        let authenticator = WhereAuthenticator(key: key, tokenStorage: tokenStorage, encoder: encoder)
        let interceptor = AuthenticationInterceptor(authenticator: authenticator)
        let session = Session(interceptor: interceptor)
        return .init(session: session)
    }
}

struct WithoutTokenAPIServiceProvider: APIServiceProvidable {
    func makeProvider<T: TargetType>(_ endpoint: T.Type) -> MoyaProvider<T> {
        return .init()
    }
}
