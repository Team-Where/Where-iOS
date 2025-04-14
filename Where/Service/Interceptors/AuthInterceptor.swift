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
    private let retryLimit: Int = 2
    
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
        else { return } // TODO: CustomError 구현 후, 에러 방출
        
        var request = urlRequest
        request.headers.add(.authorization(bearerToken: tokens.accessToken))
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount < retryLimit
        else {
            return completion(.doNotRetryWithError(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401))))
        }
        
        guard let response = request.task?.response as? HTTPURLResponse
        else {
            return completion(.doNotRetryWithError(error))
        }
        
        //TODO: 토큰 구조화하여 비교 후, 저장 및 분기 처리
        guard let newToken = response.headers["Authorization"]?.split(separator: " ").last as? String else { return completion(.doNotRetry) }
        guard let oldToken = try? fetchTokens() else { return completion(.doNotRetry) }
        
        guard newToken == oldToken.accessToken
        else {
            try? saveTokens(Tokens(accessToken: newToken, refreshToken: oldToken.refreshToken))
            return completion(.doNotRetry)
        }
        
        guard response.statusCode == 401
        else {
            return completion(.doNotRetry)
        }
        
        try? saveTokens(Tokens(accessToken: oldToken.refreshToken, refreshToken: oldToken.refreshToken))
        
        return completion(.retry)
    }
}

private extension AuthInterceptor {
    func fetchTokens() throws -> Tokens {
        do {
            let data = try tokenStorage.fetch(by: key)
            let tokens = try decoder.decode(Tokens.self, from: data)
            return tokens
        } catch let error {
            throw error
        }
    }
    
    func saveTokens(_ tokens: Tokens) throws {
        do {
            let data = try encoder.encode(tokens)
            try tokenStorage.store(data, by: key)
        } catch let error {
            throw error
        }
    }
}
