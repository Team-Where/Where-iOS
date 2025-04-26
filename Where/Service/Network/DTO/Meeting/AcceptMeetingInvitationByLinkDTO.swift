//
//  AcceptMeetingInvitationByLinkDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

import Foundation

/// 모임 초대 수락 - 링크 DTO
enum AcceptMeetingInvitationByLinkDTO {
    struct Request: Encodable {
        let userID: UInt64
        let invitationLink: String
        
        enum CodingKeys: String, CodingKey {
            case userID = "userId"
            case invitationLink = "link"
        }
    }
    
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
        
        func toEntity() -> Meeting {
            return .init(
                id: meetingID,
                title: title,
                description: description,
                imageURL: URL(string: meetingImageURLString ?? ""),
                createdAt: createdAt.toDate(by: .serverDateTimeWithMS),
                scheduleDate: scheduleDate?.toDate(by: .yyyyMMddHyphen), scheduleTime: scheduleTime?.toDate(by: .HHmmss), shareLink: URL(string: invitationLink), isFinished: isMeetingEnded
            )
        }
    }
}
