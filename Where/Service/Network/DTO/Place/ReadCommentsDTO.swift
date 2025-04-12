//
//  ReadCommentsDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

/// 코멘트 조회
enum ReadCommentsDTO {
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
