//
//  Tokens.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import Foundation
import Alamofire

struct Tokens: Codable {
    
    let accessToken: String // 30분
    let refreshToken: String // 7일
    let expiredAt: Date
    
    init(
        accessToken: String,
        refreshToken: String
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiredAt =  Date(timeIntervalSinceNow: 60 * 30)
    }
    
}

extension Tokens: AuthenticationCredential {
    var requiresRefresh: Bool { return Date(timeIntervalSinceNow: 60 * 5) >= expiredAt }
}

extension Tokens {
    enum HeaderKey: String {
        case accseeToken = "Authorization"
        case refreshToken = "Refresh-Token"
    }
}
