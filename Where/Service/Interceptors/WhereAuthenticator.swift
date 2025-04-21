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
    private let encoder: JSONEncoder
    
    init(
        tokenStorage: TokenStorageProtocol,
        encoder: JSONEncoder
    ) {
        self.tokenStorage = tokenStorage
        self.encoder = encoder
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
                        return completion(.failure(AuthenticatorError.tokenNotFound))
                    }
                    let newToken = Tokens(accessToken: access, refreshToken: credential.refreshToken)
                    
                    do {
                        try self?.saveToken(newToken)
                    } catch {
                        completion(.failure(AuthenticatorError.saveTokenFailed))
                    }
                    completion(.success(newToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

private extension WhereAuthenticator {
    enum AuthenticatorError: Error {
        case saveTokenFailed
        case tokenNotFound
    }
    
    func saveToken(_ token: Credential) throws {
        let encodedData = try encoder.encode(token)
        try tokenStorage.store(encodedData)
    }
}
