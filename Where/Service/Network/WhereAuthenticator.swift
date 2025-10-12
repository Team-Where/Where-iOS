//
//  WhereAuthenticator.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import Foundation
import Alamofire
import Moya

final class WhereAuthenticator {
    private let tokenStorage: TokenStorageProtocol
    
    init(tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }
}

extension WhereAuthenticator: Authenticator {
    typealias Credential = Tokens
    func apply(_ credential: Tokens, to urlRequest: inout URLRequest) {
        return
    }
    
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: any Error)
    -> Bool
    {
        return response.statusCode == 401
    }
    
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Tokens) -> Bool {
        let bearerToken = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        return urlRequest.headers[Tokens.HeaderKey.accseeToken.rawValue] == bearerToken
    }
    
    func refresh(
        _ credential: Tokens, for session: Alamofire.Session, completion: @escaping @Sendable (Result<Tokens, any Error>) -> Void
    ) {
        MoyaProvider<Endpoint>()
            .request(.reissueAccessToken(refreshToken: credential.refreshToken)) { [weak self] result in
                switch result {
                case .success(let response):
                    guard let access = response.response?.headers[Tokens.HeaderKey.accseeToken.rawValue]?.split(separator: " ").last as? String
                    else {
                        return completion(.failure(AuthInterceptorError.tokenNotFound))
                    }
                    let newToken = Tokens(accessToken: access, refreshToken: credential.refreshToken)
                    
                    do {
                        try self?.tokenStorage.store(newToken)
                    } catch {
                        completion(.failure(AuthInterceptorError.saveTokenFailed))
                    }
                    completion(.success(newToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

enum AuthInterceptorError: Error {
    case saveTokenFailed
    case tokenNotFound
    case notFoundTokenForHeader
}

final class AuthInterceptor: RequestInterceptor {
    private let tokenStorage: TokenStorageProtocol
    
    init(_ tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401
        else {
            completion(.doNotRetry)
            return
        }
        
        guard let token = try? tokenStorage.fetch()
        else {
            completion(.doNotRetryWithError(AuthInterceptorError.tokenNotFound))
            return
        }
        
        MoyaProvider<Endpoint>()
            .request(.reissueAccessToken(refreshToken: token.refreshToken)) { [weak self] result in
                switch result {
                case .success(let response):
                    guard let access = response.response?.headers[Tokens.HeaderKey.accseeToken.rawValue]?.split(separator: " ").last as? String
                    else {
                        return completion(.doNotRetryWithError(AuthInterceptorError.notFoundTokenForHeader))
                    }
                    let newToken = Tokens(accessToken: access, refreshToken: token.refreshToken)
                    do {
                        try self?.tokenStorage.store(newToken)
                    } catch {
                        completion(.doNotRetryWithError(AuthInterceptorError.saveTokenFailed))
                    }
                    completion(.retry)
                case .failure(let error):
                    completion(.doNotRetryWithError(error))
                }
            }
    }
}
