//
//  CreateCommentDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

/// 코멘트 작성
enum CreateCommentDTO {
    struct Request: Encodable {
        let placeID: UInt64
        let userID: UInt64
        let description: String
        
        enum CodingKeys: String, CodingKey {
            case description
            case placeID = "placeId"
            case userID = "userId"
        }
    }
    
    struct Response: Decodable {
        let commentID: UInt64
        let description: String
        
        enum CodingKeys: String, CodingKey {
            case description
            case commentID = "commentId"
        }
    }
}
