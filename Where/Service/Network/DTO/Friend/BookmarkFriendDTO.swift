//
//  BookmarkFriendDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

enum BookmarkFriendDTO {
    struct Request: Encodable {
        let userID: UInt64
        let friendID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case userID = "userId"
            case friendID = "friendId"
        }
    }
    
    struct Response: Decodable {
        let userID: UInt64
        let friendID: UInt64
        let isBookmarked: Bool
        
        enum CodingKeys: String, CodingKey {
            case userID = "userId"
            case friendID = "friendId"
            case isBookmarked = "bookmark"
        }
    }
}
