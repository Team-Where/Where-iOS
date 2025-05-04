//
//  UpdateNicknameDTO.swift
//  Where
//
//  Created by Swain Yun on 5/4/25.
//

import Foundation

enum UpdateNicknameDTO {
    struct Request: Encodable {
        let nickname: String
        
        enum CondingKeys: String, CodingKey {
            case nickname = "nickName"
        }
    }
}
