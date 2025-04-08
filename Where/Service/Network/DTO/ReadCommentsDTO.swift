//
//  ReadCommentsDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

enum ReadCommentsDTO {
    struct Request: Encodable {
        let placeID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case placeID = "id"
        }
    }
    
    typealias Response = [Comment]
}

extension ReadCommentsDTO {
    struct Comment: Decodable {
        let id: UInt64
        let placeID: UInt64
        let description: String
        
        enum CodingKeys: String, CodingKey {
            case id, description
            case placeID = "placeId"
        }
    }
}
