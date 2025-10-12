//
//  LeaveMeetingDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 모임 탈퇴 DTO
enum LeaveMeetingDTO {
    
    struct Request: Encodable {
        let meetingID: UInt64
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "id"
            case userID = "userId"
        }
    }
}
