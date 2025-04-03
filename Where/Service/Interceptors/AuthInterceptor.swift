//
//  AuthInterceptor.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import Foundation
import Alamofire
import Moya

final class AuthInterceptor: RequestInterceptor {
    private let key: UInt64
    private let tokenStorage: TokenStorageProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        key: UInt64,
        tokenStorage: TokenStorageProtocol,
        _ decoder: JSONDecoder,
        _ encoder: JSONEncoder
    ) {
        self.key = key
        self.tokenStorage = tokenStorage
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        guard let data = try? tokenStorage.fetch(by: key),
              let tokens = try? decoder.decode(Tokens.self, from: data)
        else { return }
        
        var request = urlRequest
        request.headers.add(.authorization(bearerToken: tokens.accessToken))
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            return completion(.doNotRetryWithError(error))
        }
        
        guard response.statusCode == 401 else {
            return completion(.doNotRetry)
        }
        
        guard let data = try? tokenStorage.fetch(by: key),
              let tokens = try? decoder.decode(Tokens.self, from: data)
        else {
            return completion(.doNotRetry)
        }
        
//        let provider = MoyaProvider()
    }
}
