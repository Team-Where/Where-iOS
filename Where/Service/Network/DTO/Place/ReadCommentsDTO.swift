//
//  ReadCommentsDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// 코멘트 조회
enum ReadCommentsDTO {
    typealias Response = [CommentDetail]
}

extension ReadCommentsDTO {
    struct CommentDetail: Decodable {
        let id: UInt64
        let placeID: UInt64
        let description: String
        let createdAt: String?
        let isMyComment: Bool
        
        enum CodingKeys: String, CodingKey {
            case id, description, createdAt
            case placeID = "placeId"
            case isMyComment = "isMine"
        }
        
        func toEntity() -> Comment {
            .init(
                id: id,
                placeId: placeID,
                description: description,
                isMyComment: isMyComment,
                createdAt: createdAt?.toDate(by: .serverDateTimeWithMS) ?? .now
            )
        }
    }
}
