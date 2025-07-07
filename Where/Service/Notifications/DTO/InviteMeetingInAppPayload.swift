//
//  InviteMeetingInAppPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct InviteMeetingInAppPayload {
    let inviteID: UInt64
    let meetingID: UInt64
    let meetingImage: String?
    let hostNickname: String
    let meetingTitle: String
    let scheduleDate: String?
    let scheduleTime: String?
    
    private let basePayload: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo)
        else {
            return nil
        }
        guard let inviteID  = userInfo["inviteId"] as? UInt64,
              let meetingID = userInfo["meetingId"] as? UInt64
        else {
            return nil
        }
        
        guard let hostNickname = userInfo["fromNickName"] as? String,
              let meetingTitle = userInfo["meetingTitle"] as? String
        else {
            return nil
        }
        self.basePayload = basePayload
        
        self.inviteID = inviteID
        self.meetingID = meetingID
        self.meetingImage = userInfo["meetingImage"] as? String
        self.hostNickname = hostNickname
        self.meetingTitle = meetingTitle
        self.scheduleDate = userInfo["scheduleDate"] as? String
        self.scheduleTime = userInfo["scheduleTime"] as? String
    }
}

extension InviteMeetingInAppPayload: PayloadType  {
    var id: UInt64 {
        basePayload.id
    }
    
    var title: String {
        basePayload.title
    }
    
    var content: String {
        basePayload.content
    }
    
    var type: NotificationType {
        basePayload.type
    }
}
