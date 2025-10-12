//
//  DeleteFriendDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// 친구 삭제
enum DeleteFriendDTO {
    struct Request: Encodable {
        let userID: UInt64
        let friendID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case userID = "userId"
            case friendID = "friendId"
        }
    }
}
