//
//  AuthentificationProvider.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import Foundation

/// 로그인 타입 정의 (소셜 로그인, 자체 로그인)
enum AuthentificationProvider: String {
    case apple
    case kakao
    case naver
    case custom
    
    init?(identifier: String) {
        self.init(rawValue: identifier)
    }
    
    var identifier: String {
        self.rawValue
    }
}
