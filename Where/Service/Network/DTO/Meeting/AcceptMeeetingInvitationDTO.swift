//
//  AcceptMeeetingInvitationDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

/// 모임 초대 수락 DTO
struct AcceptMeeetingInvitationDTO {
    struct Request: Encodable {
        let invitationID: String
        
        enum CodingKeys: String, CodingKey {
            case invitationID = "id"
        }
    }
    
    struct Respnse: Decodable {
        let meetingID: UInt64
        let title: String
        let description: String
        let invitationLink: String
        let meetingImageURLString: String?
        let isMeetingEnded: Bool
        let createdAt: String
        let scheduleDate: String?
        let scheduleTime: String?
        
        enum CodingKeys: String, CodingKey {
            case meetingID = "id"
            case invitationLink = "link"
            case meetingImageURLString = "image"
            case isMeetingEnded = "finished"
            case title, description, createdAt, scheduleDate, scheduleTime
        }
    }
}
