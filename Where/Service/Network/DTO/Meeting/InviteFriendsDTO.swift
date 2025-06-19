//
//  InviteFriendsDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 모임 초대 DTO
enum InviteFriendsDTO {
    struct Request: Encodable {
        let meetingID: UInt64
        let hostID: UInt64
        let guestID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "meetingId"
            case hostID = "fromId"
            case guestID = "toId"
        }
    }
}
