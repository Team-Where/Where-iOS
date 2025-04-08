//
//  AcceptMeetingInvitationByLinkDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

enum AcceptMeetingInvitationByLinkDTO {
    
    /// 모임 초대 수락 - 링크 RequestDTO
    struct Request: Encodable {
        let userID: UInt64
        let invitationLink: String
        
        enum CodingKeys: String, CodingKey {
            case userID = "userId"
            case invitationLink = "link"
        }
    }
    
    /// 모임 초대 수락 - 링크 ResponseDTO
    struct Response: Decodable {
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
