//
//  ReadFAQsDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// FAQ 조회
enum ReadFAQsDTO {
    struct Response: Decodable {
        let id: UInt64
        let title: String
        let content: String
        let modifiedAt: Date
        
        enum CodingKeys: String, CodingKey {
            case id, title, content
            case modifiedAt = "date"
        }
    }
}
