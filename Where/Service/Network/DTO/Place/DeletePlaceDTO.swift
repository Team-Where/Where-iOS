//
//  DeletePlaceDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// 장소 삭제
enum DeletePlaceDTO {
    struct Request: Encodable {
        let id: UInt64
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "userId"
        }
    }
}
