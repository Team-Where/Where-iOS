//
//  ReadFAQsDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

/// FAQ 조회
enum ReadFAQsDTO {
    struct Response: Decodable {
        let id: UInt64
        let title: String
        let content: String
    }
}
