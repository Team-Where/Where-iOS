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
}
