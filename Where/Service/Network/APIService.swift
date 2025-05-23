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
    func requestPublisher<T: TargetType, D: Decodable>(_ targetType: T, _ DTO: D.Type) -> AnyPublisher<D, Error>
    func requestPublisher<T: TargetType>(_ targetType: T) -> AnyPublisher<String, Error>
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
//        let authenticator = WhereAuthenticator(tokenStorage: tokenStorage)
//        let interceptor = AuthenticationInterceptor(authenticator: authenticator)
        let interceptor = AuthInterceptor(tokenStorage)
        let session = Session(interceptor: interceptor)
        
        provider = .init(session: session, plugins: [TokenPlugin(tokenStorage: tokenStorage)])
    }
    
    private func performResponse(_ response: Publishers.HandleEvents<AnyPublisher<Response, MoyaError>>.Output) throws -> Data {
        guard (200..<300).contains(response.statusCode) else {
            throw MoyaError.statusCode(response)
        }
        return response.data
    }
    
    func requestPublisher<T: TargetType, D: Decodable>(_ targetType: T, _ DTO: D.Type) -> AnyPublisher<D, Error> {
        
        return provider.requestPublisher(MultiTarget(targetType))
            .handleEvents(receiveOutput: { response in
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print(jsonString)
                }
            })
            .handleEvents(receiveCompletion: { completion in
                #if DEBUG
                guard case .failure(let error) = completion else { return }
                print("Error Occured in Networking: \(error)")
                #endif
            })
            .tryMap { response in
                try self.performResponse(response)
            }
            .decode(type: D.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func requestPublisher<T: TargetType>(_ targetType: T) -> AnyPublisher<String, Error> {
        return provider.requestPublisher(MultiTarget(targetType))
            .tryMap { response in
                let data = try self.performResponse(response)
                
                guard let string = String(data: data, encoding: .utf8) else {
                    throw MoyaError.stringMapping(response)
                }
                print(string)
                return string
            }
            .eraseToAnyPublisher()
    }
    
}
