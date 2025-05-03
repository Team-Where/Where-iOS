//
//  LoginWithKakaoDTO.swift
//  Where
//
//  Created by Swain Yun on 5/2/25.
//

import Foundation

enum LoginWithKakaoDTO {
    struct Response: Decodable {
        let userID: UInt64
        let isRegistrationNeeded: Bool
        
        enum CodingKeys: String, CodingKey {
            case userID = "userId"
            case isRegistrationNeeded = "signUp"
        }
    }
}
