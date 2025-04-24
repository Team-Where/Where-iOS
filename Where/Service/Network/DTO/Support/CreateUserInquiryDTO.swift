//
//  CreateUserInquiryDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

import Foundation

/// 1:1 문의 작성 - 사용자
enum CreateUserInquiryDTO {
    struct Request: Encodable {
        let title: String
        let content: String
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case userID = "userId"
            case title, content
        }
    }
    
    struct Response: Decodable {
        let inquiryID: UInt64
        let title: String
        let content: String
        let imageURLStrings: [String]?
        let isAnswered: Bool
        let answerContent: String?
        let modifiedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case inquiryID = "id"
            case title, content, answerContent
            case imageURLStrings = "images"
            case isAnswered = "answered"
            case modifiedAt = "inquiryDate"
        }
        
        func toEntity() -> Inquiry {
            .init(
                id: inquiryID,
                modifiedAt: modifiedAt,
                title: title,
                content: content,
                imageURLs: (imageURLStrings ?? []).compactMap { URL(string: $0) },
                isAnswered: isAnswered,
                answerContent: answerContent
            )
        }
    }
}
