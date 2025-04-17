//
//  AuthInterceptor.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import Foundation
import Alamofire

final class AuthInterceptor {
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
    
    private func fetchTokens() throws -> Tokens {
        guard let data = try? tokenStorage.fetch(by: key),
              let tokens = try? decoder.decode(Tokens.self, from: data)
        else {
            throw AuthInterceptorError.tokenNotFound
        }
        return tokens
    }
    
    private func saveTokens(_ tokens: Tokens) throws {
        guard let data = try? encoder.encode(tokens),
              (try? tokenStorage.store(data, by: key)) != nil
        else {
            throw AuthInterceptorError.saveTokenFailed
        }
    }
}

// MARK: - Nested Types

private extension AuthInterceptor {
    enum AuthInterceptorError: Error {
        case saveTokenFailed
        case tokenNotFound
        case refreshTokenExpired
    }
}

// MARK: - Interfaces

extension AuthInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        do {
            let tokens = try fetchTokens()
            var request = urlRequest
            request.headers.add(.authorization(bearerToken: tokens.accessToken))
            completion(.success(request))
        } catch {
            completion(.failure(error))
        }
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount < retryLimit
        else {
            return completion(.doNotRetryWithError(AuthInterceptorError.refreshTokenExpired))
        }
        
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401
        else {
            return completion(.doNotRetryWithError(error))
        }
        
        do {
            let oldToken = try fetchTokens()
            try saveTokens(Tokens(accessToken: oldToken.refreshToken, refreshToken: oldToken.refreshToken))
            
            completion(.retry)
            
        } catch let error {
            completion(.doNotRetryWithError(error))
        }
    }
}
