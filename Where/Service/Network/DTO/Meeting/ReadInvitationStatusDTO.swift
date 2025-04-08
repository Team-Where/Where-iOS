//
//  ReadInvitationStatusDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 모임 초대 현황 조회 DTO
enum ReadInvitationStatusDTO {
    struct Request: Encodable {
        let meetingID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "id"
        }
    }
    
    typealias Response = [InvitationInfo]
}

extension ReadInvitationStatusDTO {
    struct InvitationInfo: Decodable {
        let hostID: UInt64
        let hostName: String
        let guestID: UInt64
        let guestName: String
        let status: Bool
        let hostImageURLString: String?
        
        enum CodingKeys: String, CodingKey {
            case hostID = "fromId"
            case hostName = "fromName"
            case guestID = "toId"
            case guestName = "toName"
            case status
            case hostImageURLString = "toImage"
        }
    }
}
