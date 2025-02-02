//
//  AuthentificationProvider.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import Foundation

/// O-Auth 공급자 종류
enum AuthentificationProvider {
    case apple
    case kakao
    case naver
    
    /// Bundle 검색에 필요한 키
    var infoDictionaryKey: String {
        switch self {
        case .apple: "APPLE_NATIVE_APP_KEY"
        case .kakao: "KAKAO_NATIVE_APP_KEY"
        case .naver: "NAVER_NATIVE_APP_KEY"
        }
    }
}
