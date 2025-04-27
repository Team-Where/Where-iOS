//
//  AcceptMeeetingInvitationDTO.swift
//  Where
//
//  Created by BOMBSGIE on 4/8/25.
//

import Foundation
/// 모임 초대 수락 DTO
struct AcceptMeeetingInvitationDTO {
    struct Request: Encodable {
        let invitationID: UInt64
        
        enum CodingKeys: String, CodingKey {
            case invitationID = "id"
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
            guard let imageString = meetingImageURLString
            else {
                return .init(id: meetingID,
                             title: title,
                             description: description,
                             createdAt: createdAt.toDate(by: .serverDateTimeWithMS) ?? .now,
                             isFinished: isMeetingEnded)
            }
            return .init(
                id: meetingID,
                title: title,
                description: description,
                imageURL: URL(string: imageString),
                createdAt: createdAt.toDate(by: .serverDateTimeWithMS) ?? .now,
                scheduleDate: scheduleDate?.toDate(by: .yyyyMMddHyphen),
                scheduleTime: scheduleTime?.toDate(by: .HHmmss),
                shareLink: URL(string: invitationLink),
                isFinished: isMeetingEnded
            )
        }
    }
}
