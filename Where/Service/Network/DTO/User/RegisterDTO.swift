//
//  RegisterDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/15/25.
//

import Foundation

/// 회원가입DTO
enum RegisterDTO {
    struct Request: Encodable {
        let email: String
        let password: String
        let nickname: String
        
        enum CondingKeys: String, CodingKey {
            case email, password
            case nickname = "nickName"
        }
    }
    
    struct Response: Decodable {
        let id: UInt64
        let email: String
        let nickname: String
        let profileImageURLString: String?
        let isNicknameDuplicated: Bool
        
        enum CodingKeys: String, CodingKey {
            case id, email
            case nickname = "nickName"
            case profileImageURLString = "profileImage"
            case isNicknameDuplicated = "existsByNickName"
        }
        
        func toEntity() -> User {
            .init(
                id: id,
                nickname: nickname,
                createdAt: .now,
                imageURL: URL(string: profileImageURLString ?? "")
            )
        }
    }
}
