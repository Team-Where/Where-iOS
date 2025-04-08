//
//  ReadFAQsDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// FAQ 조회
enum ReadFAQsDTO {
    struct Response {
        let id: UInt64
        let title: String
        let content: String
    }
}
