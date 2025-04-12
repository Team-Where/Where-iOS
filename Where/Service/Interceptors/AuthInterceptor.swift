//
//  AuthInterceptor.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {
    private let key: UInt64
    private let tokenStorage: TokenStorageProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let apiProvider: APIServiceProvidable
    
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
        self.apiProvider = WithoutTokenAPIServiceProvider()
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
        
        let provider = apiProvider.makeProvider(Endpoint.self)
        
        provider.request(.readFAQs) {[weak self] result in
            switch result {
            case .success(let response):
                guard let header = self?.hadleResponse(response.response),
                      let tokens = self?.asTokens(with: header),
                      self?.isTokenUpdated(tokens) == true
                else {
                    return completion(.doNotRetry)
                }
                session.session.configuration.headers.add(.authorization(bearerToken: tokens.accessToken))
                completion(.retry)
            case .failure(let error):
                completion(.doNotRetryWithError(error))
            }
        }
    }
}

private extension AuthInterceptor {
    func hadleResponse(_ response: HTTPURLResponse?) -> [String: String]? {
        guard let response = response else { return nil }
        guard (200..<300).contains(response.statusCode) else { return nil }
        return response.allHeaderFields as? [String: String]
    }
    
    func asTokens(with headers: [String: String]) -> Tokens {
        let accessToken = headers["Authorization"] ?? String()
        let refreshToken = headers["Authorization_refresh"] ?? String()
        return Tokens(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    func isTokenUpdated(_ token: Tokens) -> Bool {
        guard let encodedTokenData = try? encoder.encode(token),
              (try? tokenStorage.store(encodedTokenData, by: key)) != nil
        else {
            return false
        }
        
        return true
    }
}
