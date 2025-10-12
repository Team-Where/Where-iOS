//
//  CreateFAQDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// FAQ 등록
enum CreateFAQDTO {
    struct Request: Encodable {
        let title: String
        let content: String
    }
    
    struct Response: Decodable {
        let id: UInt64
        let title: String
        let content: String
        let modifiedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case id, title, content
            case modifiedAt = "date"
        }
        
        func toEntity() -> Announcement {
            .init(
                id: id,
                title: title,
                content: content,
                date: modifiedAt,
                type: .FAQ
            )
        }
    }
}
