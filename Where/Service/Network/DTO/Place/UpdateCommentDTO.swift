//
//  UpdateCommentDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

/// 코멘트 수정
enum UpdateCommentDTO {
    struct Request: Encodable {
        let id: UInt64
        let userID: UInt64
        let description: String
        
        enum CodingKeys: String, CodingKey {
            case id, description
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
