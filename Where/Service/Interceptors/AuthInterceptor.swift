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
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        guard let data = try? tokenStorage.fetch(by: key),
              let tokens = try? decoder.decode(Tokens.self, from: data)
        else {
            return completion(.failure(AuthInterceptorError.tokenNotFound))
        }
        
        var request = urlRequest
        request.headers.add(.authorization(bearerToken: tokens.accessToken))
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount < retryLimit
        else {
            return completion(.doNotRetryWithError(AuthInterceptorError.refreshTokenExpired))
        }
        
        guard let response = request.task?.response as? HTTPURLResponse
        else {
            return completion(.doNotRetryWithError(error))
        }
        
        //TODO: 한 트랜잭션으로 리팩 -> 단일 do-catch 구문으로 래핑, 불필요 guard-else 구문 제거
        guard let newToken = extractTokens(from: response.headers) else { return completion(.doNotRetryWithError(AuthInterceptorError.headerMissing)) }
        guard let oldToken = fetchTokens() else { return completion(.doNotRetryWithError(AuthInterceptorError.tokenNotFound)) }
        
        guard newToken == oldToken
        else {
            return saveTokens(newToken, completion)
        }
        
        guard response.statusCode == 401
        else {
            return completion(.doNotRetryWithError(AuthInterceptorError.anotherResponse(statusCode: response.statusCode)))
        }
        
        saveTokens(Tokens(accessToken: oldToken.refreshToken, refreshToken: oldToken.refreshToken), completion)
        
        return completion(.retry)
    }
}

private extension AuthInterceptor {
    func extractTokens(from header: HTTPHeaders) -> Tokens? {
        guard let accessToken = header["AccessToken"],
              let refreshToken = header["RefreshToken"]
        else { return nil }
        return Tokens(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    func fetchTokens() -> Tokens? {
        guard let data = try? tokenStorage.fetch(by: key),
              let tokens = try? decoder.decode(Tokens.self, from: data)
        else { return nil }
        return tokens
    }
    
    func saveTokens(_ tokens: Tokens, _ completion: (RetryResult) -> Void) {
        do {
            let data = try encoder.encode(tokens)
            try tokenStorage.store(data, by: key)
        } catch let error {
            completion(.doNotRetryWithError(AuthInterceptorError.saveTokenFailed))
        }
    }
}

// MARK: - Nested Types
private extension AuthInterceptor {
    enum AuthInterceptorError: Error {
        case anotherResponse(statusCode: Int)
        case headerMissing
        case saveTokenFailed
        case tokenNotFound
        case refreshTokenExpired
    }
}
