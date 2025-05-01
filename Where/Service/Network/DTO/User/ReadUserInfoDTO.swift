//
//  ReadUserInfoDTO.swift
//  Where
//
//  Created by Swain Yun on 5/1/25.
//

import Foundation

enum ReadUserInfoDTO {
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
