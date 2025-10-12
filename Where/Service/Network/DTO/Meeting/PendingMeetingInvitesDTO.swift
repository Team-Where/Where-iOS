//
//  PendingMeetingInvitesDTO.swift
//  Where
//
//  Created by BOMBSGIE on 7/21/25.
//

import Foundation

enum PendingMeetingInvitesDTO {
    typealias Response = [PendingMeetingDTO]
}

extension PendingMeetingInvitesDTO {
    struct PendingMeetingDTO: Decodable {
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
        
        
        func toEntity() -> PendingMeeting {
            return .init(inviteID: inviteID,
                         meetingID: meetingID,
                         meetingImageURL: URL(string: meetingImageURL ?? ""),
                         hostNickname: hostNickname,
                         meetingTitle: meetingTitle,
                         scheduleDate: scheduleDate?.toDate(by: .yyyyMMddHyphen),
                         scheduleTime: scheduleTime?.toDate(by: .HHmmss))
        }
    }
}
