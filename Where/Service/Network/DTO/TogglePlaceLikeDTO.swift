//
//  TogglePlaceLikeDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

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
        let isLike: Bool
        let pickedState: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case isLike = "like"
            case pickedState = "placeStatus"
        }
    }
}
