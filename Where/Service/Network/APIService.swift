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
    func requestVoidPublisher<T: TargetType>(_ targetType: T) -> AnyPublisher<Void, Error>
    func requestStringPublisher<T: TargetType>(_ targetType: T) -> AnyPublisher<String, Error>
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
        let interceptor = AuthInterceptor(tokenStorage)
        let session = Session(interceptor: interceptor)
        
        provider = .init(session: session, plugins: [TokenPlugin(tokenStorage: tokenStorage)])
    }
    
    private func performResponse(_ response: Publishers.HandleEvents<AnyPublisher<Response, MoyaError>>.Output) throws -> Data? {
        guard (200..<300).contains(response.statusCode) else {
            throw MoyaError.statusCode(response)
        }
        return response.data.isEmpty ? nil : response.data
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
                guard let data = try self.performResponse(response) else {
                    throw MoyaError.jsonMapping(response)
                }
                return data
            }
            .decode(type: D.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func requestVoidPublisher<T: TargetType>(_ targetType: T) -> AnyPublisher<Void, Error> {
        return provider.requestPublisher(MultiTarget(targetType))
            .handleEvents(receiveCompletion: { completion in
                #if DEBUG
                guard case .failure(let error) = completion else { return }
                print("Error Occured in Networking: \(error)")
                #endif
            })
            .tryMap { response in
                _ = try self.performResponse(response)
                return ()
            }
            .eraseToAnyPublisher()
    }
    
    func requestStringPublisher<T: TargetType>(_ targetType: T) -> AnyPublisher<String, Error> {
        return provider.requestPublisher(MultiTarget(targetType))
            .tryMap { response in
                guard let data = try self.performResponse(response),
                      let string = String(data: data, encoding: .utf8)
                else { throw MoyaError.stringMapping(response) }
                print(string)
                return string
            }
            .eraseToAnyPublisher()
    }
}
