//
//  LeaveMeetingDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

enum LeaveMeetingDTO {
    /// 모임 탈퇴 RequestDTO
    struct Request: Encodable {
        let meetingID: UInt64
        let userID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "id"
            case userID = "userId"
        }
    }
}
