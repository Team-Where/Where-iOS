//
//  ReadInvitationStatusDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 모임 초대 현황 조회 DTO
enum ReadInvitationStatusDTO {
    typealias Response = [InvitationInfo]
}

extension ReadInvitationStatusDTO {
    struct InvitationInfo: Decodable {
        let hostID: UInt64
        let hostName: String
        let guestID: UInt64
        let guestName: String
        let isInvited: Bool
        let guestImageURLString: String?
        
        enum CodingKeys: String, CodingKey {
            case hostID = "fromId"
            case hostName = "fromName"
            case guestID = "toId"
            case guestName = "toName"
            case isInvited = "status"
            case guestImageURLString = "toImage"
        }
        
        func toEntity() -> MeetingInvitationState {
            return .init(
                hostID: hostID,
                hostName: hostName,
                guestID: guestID,
                guestName: guestName,
                isInvited: isInvited,
                guestImageURLString: guestImageURLString
            )
        }
    }
}
