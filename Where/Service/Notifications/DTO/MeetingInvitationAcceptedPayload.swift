//
//  MeetingInvitationAcceptedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct MeetingInvitationAcceptedPayload: PayloadType {
    let meetingID: UInt64
    let userID: UInt64
    let userName: String
    let userImage: String?
    
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo)
        else {
            return nil
        }
        guard let meetingID = userInfo[UserInfoKey.meetingId.rawValue] as? UInt64,
              let userID = userInfo[UserInfoKey.userId.rawValue] as? UInt64,
              let userName = userInfo[UserInfoKey.userName.rawValue] as? String
        else {
            return nil
        }
        self.meetingID = meetingID
        self.userID = userID
        self.userName = userName
        self.userImage = userInfo[UserInfoKey.userImage.rawValue] as? String
        _base = basePayload
    }
}
