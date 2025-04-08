//
//  DeleteScheduleDTO.swift
//  Where
//
//  Created by Swain Yun on 4/8/25.
//

import Foundation

/// 일정 삭제
enum DeleteScheduleDTO {
    struct Request: Encodable {
        let meetingID: UInt64
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "meetingId"
            case userID = "userId"
        }
    }
}
