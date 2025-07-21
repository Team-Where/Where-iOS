//
//  PendingMeetingInvitesDTO.swift
//  Where
//
//  Created by BOMBSGIE on 7/21/25.
//

import Foundation

enum PendingMeetingInvitesDTO {
    typealias Response = [PendingMeeting]
}

extension PendingMeetingInvitesDTO {
    struct PendingMeeting {
        let inviteID: UInt64
        let meetingID: UInt64
        let meetingImageURL: String?
        let hostNickname: String
        let meetingTitle: String
        let scheduleDate: String?
        let scheduleTime: String?
        
        enum CodingKeys: String, CodingKey {
            case inviteID = "inviteId"
            case meetingID = "meetingId"
            case meetingImageURL = "meetingImage"
            case hostNickname = "fromNickName"
            case meetingTitle, scheduleDate, scheduleTime
        }
        
        func toEntity() -> Meeting {
            return .init(id: <#T##UInt64#>, title: <#T##String#>, description: <#T##String#>, createdAt: <#T##Date#>, isFinished: <#T##Bool#>)
        }
    }
}
