//
//  TokenPlugin.swift
//  Where
//
//  Created by BOMBSGIE on 4/21/25.
//

import Foundation
import Moya

final class TokenPlugin: PluginType {
    private let tokenStorage: TokenStorageProtocol
    
    init(tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }
    
    func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
        guard let multiTarget = target as? MultiTarget,
              let endpoint = multiTarget.target as? Endpoint,
              endpoint.isTokenRequired
        else {
            return request
        }
        
        do {
            var tokenRequest = request
            
            if case .loginWithKakao(let accessToken, let refreshToken) = endpoint {
                tokenRequest.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
                tokenRequest.setValue("\(refreshToken)", forHTTPHeaderField: "refreshToken")
            } else {
                let token = try tokenStorage.fetch()
                tokenRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            return tokenRequest
        } catch {
            return request
        }
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: any TargetType) {
        guard let multiTarget = target as? MultiTarget,
              let endpoint = multiTarget.target as? Endpoint,
              endpoint.shouldSaveToken
        else {
            return
        }
        
        switch result {
        case .success(let response):
            guard let accessToken = response.response?.headers[Tokens.HeaderKey.accseeToken.rawValue]?.split(separator: " ").last as? String,
                  let refreshToken = response.response?.headers[Tokens.HeaderKey.refreshToken.rawValue] as? String
            else {
                #if DEBUG
                print("\(#function) Error: Failed to extract tokens from headers")
                #endif
                return
            }
            let token = Tokens(accessToken: accessToken, refreshToken: refreshToken)
            do {
                try tokenStorage.store(token)
            } catch {
                #if DEBUG
                print("\(#function) Error: Failed to save Token")
                #endif
                return
            }
        case .failure(let error):
            #if DEBUG
            print("\(#function) Error:\(error)")
            #endif
        }
    }

}
