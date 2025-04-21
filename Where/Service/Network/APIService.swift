//
//  APIService.swift
//  Where
//
//  Created by BOMBSGIE on 4/12/25.
//

import Combine
import Foundation

import Alamofire
import Moya
import CombineMoya

protocol APIServable {
    func requestPublisher<T: TargetType, D: Decodable>(_ targetType: T) -> AnyPublisher<D, Error>
}

final class APIService: APIServable {
    private let provider: MoyaProvider<MultiTarget>
    private let decoder: JSONDecoder
    
    init(
        _ decoder: JSONDecoder,
        _ encoder: JSONEncoder,
        _ tokenStorage: TokenStorageProtocol
    ) {
        self.decoder = decoder
        let authenticator = WhereAuthenticator(tokenStorage: tokenStorage, encoder: encoder)
        let interceptor = AuthenticationInterceptor(authenticator: authenticator)
        let session = Session(interceptor: interceptor)
        provider = .init(session: session)
    }
    
    func requestPublisher<T, D>(_ targetType: T) -> AnyPublisher<D, any Error> where T : TargetType, D : Decodable {
        
        return provider.requestPublisher(MultiTarget(targetType))
            .tryMap { response in
                guard (200..<300).contains(response.statusCode)
                else {
                    throw MoyaError.statusCode(response)
                }
                return response.data
            }
            .decode(type: D.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
}
