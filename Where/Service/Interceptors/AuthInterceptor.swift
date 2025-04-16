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
    
    private func extractTokens(from header: HTTPHeaders) throws -> Tokens {
        guard let accessToken = header["AccessToken"],
              let refreshToken = header["RefreshToken"]
        else {
            throw AuthInterceptorError.headerMissing
        }
        return Tokens(accessToken: accessToken, refreshToken: refreshToken)
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
    
    private func handleTokens(new: Tokens, old: Tokens) throws {
        if new == old {
            // 토큰이 같다는 건 재발급 전이라는 의미이므로 refreshToken 저장하고 재시도
            let tokens = Tokens(accessToken: old.refreshToken, refreshToken: old.refreshToken)
            try saveTokens(tokens)
        } else {
            // 토큰이 다르다는 건 accessToken, refreshToken 모두 실패하여 재발급한 경우이므로 새 토큰을 저장
            try saveTokens(new)
        }
    }
    
    private func performResponse(_ response: HTTPURLResponse) throws {
        guard response.statusCode == 401 else {
            throw AuthInterceptorError.anotherResponse(statusCode: response.statusCode)
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

/// MARK: - Interfaces
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
        
        guard let response = request.task?.response as? HTTPURLResponse
        else {
            return completion(.doNotRetryWithError(error))
        }
        
        do {
            try performResponse(response)
            
            
            
            let newToken = try extractTokens(from: response.headers)
            
            
            
            let oldToken = try fetchTokens()
            
            
            
            try handleTokens(new: newToken, old: oldToken)
            
            
            
            completion(.retry)
            
            
            
        } catch AuthInterceptorError.headerMissing {
            completion(.doNotRetry)
        } catch let error {
            completion(.doNotRetryWithError(error))
        }
    }
}

/*
 장소가져오기(토큰필요)
 
 1. 성공 200~300
 2. 만료 401
 
 1트: 401 / 헤더없음 / 바디없음
 2트:
 
 */
