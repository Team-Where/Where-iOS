//
//  UserCredential.swift
//  Where
//
//  Created by Swain Yun on 3/1/25.
//

import Foundation

/// OAuth2 인가 과정을 통해 생성된 정보
struct UserCredential {
    /// 애플 서버 인가에 사용되는 일회성 코드
    /// - Note: 서버에서는 이 코드를 인증 서버로 보내 토큰을 획득할 수 있음
    let authorizationCode: Data?
    
    /// 소셜 로그인 공급자에서 얻은 액세스 토큰
    let accessToken: String?
    /// 소셜 로그인 공급자에서 얻은 리프레시 토큰
    let refreshToken: String?
    
    init(
        authorizationCode: Data? = nil,
        accessToken: String? = nil,
        refreshToken: String? = nil
    ) {
        self.authorizationCode = authorizationCode
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
