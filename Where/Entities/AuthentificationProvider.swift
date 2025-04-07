//
//  AuthentificationProvider.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import Foundation
import AuthenticationServices

/// 로그인 타입 정의 (소셜 로그인, 자체 로그인)
enum AuthentificationProvider: Hashable {
    case apple(auth: ASAuthorization)
    case kakao
    case naver
    case custom(email: String, password: String)
    
    var identifier: String {
        switch self {
        case .apple: "apple"
        case .kakao: "kakao"
        case .naver: "naver"
        case .custom: "custom"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
