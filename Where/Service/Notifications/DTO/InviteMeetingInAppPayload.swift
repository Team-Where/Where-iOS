//
//  InviteMeetingInAppPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct InviteMeetingInAppPayload: PayloadType {
    let inviteID: UInt64
    let meetingID: UInt64
    let meetingImage: String?
    let hostNickname: String
    let meetingTitle: String
    let scheduleDate: String?
    let scheduleTime: String?
    
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo)
        else {
            return nil
        }
        guard let inviteID  = userInfo[UserInfoKey.inviteId.rawValue] as? UInt64,
              let meetingID = userInfo[UserInfoKey.meetingId.rawValue] as? UInt64
        else {
            return nil
        }
        
        guard let hostNickname = userInfo[UserInfoKey.fromNickName.rawValue] as? String,
              let meetingTitle = userInfo[UserInfoKey.meetingTitle.rawValue] as? String
        else {
            return nil
        }
        self._base = basePayload
        
        self.inviteID = inviteID
        self.meetingID = meetingID
        self.meetingImage = userInfo[UserInfoKey.meetingImage.rawValue] as? String
        self.hostNickname = hostNickname
        self.meetingTitle = meetingTitle
        self.scheduleDate = userInfo[UserInfoKey.scheduleDate.rawValue] as? String
        self.scheduleTime = userInfo[UserInfoKey.scheduleTime.rawValue] as? String
    }
}

extension InviteMeetingInAppPayload {
    func asMeeting() -> Meeting {
        return .init(
            id: meetingID,
            title: meetingTitle,
            description: "",
            imageURL: URL(string: meetingImage ?? ""),
            createdAt: .now,
            scheduleDate: scheduleDate?.toDate(by: .yyyyMMdd),
            scheduleTime: scheduleTime?.toDate(by: .ah),
            isFinished: false
        )
    }
}
