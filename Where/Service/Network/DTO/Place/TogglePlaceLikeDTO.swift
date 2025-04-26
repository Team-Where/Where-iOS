//
//  TogglePlaceLikeDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

/// 장소 좋아요 변경
enum TogglePlaceLikeDTO {
    struct Request: Encodable {
        let id: UInt64
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "userId"
        }
    }
    
    struct Response: Decodable {
        let id: UInt64
        let isLikedByMe: Bool
        let likesCount: Int
        let pickedState: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case isLikedByMe = "myLike"
            case likesCount = "likes"
            case pickedState = "placeStatus"
        }
    }
}
