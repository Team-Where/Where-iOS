//
//  InviteFriendsDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

enum InviteFriendsDTO {
    /// 모임 초대 RequestDTO
    struct Request: Encodable {
        let meetingID: UInt64
        let hostID: UInt64
        let guestID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "id"
            case hostID = "fromId"
            case guestID = "toId"
        }
    }
}
