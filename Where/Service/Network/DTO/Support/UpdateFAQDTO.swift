//
//  UpdateFAQDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

/// FAQ 수정
enum UpdateFAQDTO {
    struct Request: Encodable {
        let id: UInt64
        let title: String?
        let content: String?
    }
    
    struct Response: Decodable {
        let id: UInt64
        let title: String
        let content: String
    }
}
