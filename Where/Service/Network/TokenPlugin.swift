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
            let token = try tokenStorage.fetch()
            var tokenRequest = request
            tokenRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return tokenRequest
        } catch {
            return request
        }
    }
}
