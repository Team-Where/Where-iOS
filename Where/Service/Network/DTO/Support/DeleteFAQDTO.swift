//
//  DeleteFAQDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// FAQ 삭제
enum DeleteFAQDTO {
    struct Request: Encodable {
        let id: UInt64
    }
}
