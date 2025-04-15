//
//  Tokens.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import Foundation

struct Tokens: Codable, Equatable {
    let accessToken: String // 30분
    let refreshToken: String // 7일
    let expiredAt: Date
    
    var isExpired: Bool { return Date(timeIntervalSinceNow: 60 * 5) >= expiredAt }
    
    init(
        accessToken: String,
        refreshToken: String
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiredAt =  Date(timeIntervalSinceNow: 60 * 30)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.accessToken == rhs.accessToken && lhs.refreshToken == rhs.refreshToken
    }
}
