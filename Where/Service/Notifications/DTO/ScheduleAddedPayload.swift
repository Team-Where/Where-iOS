//
//  ScheduleAddedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct ScheduleAddedPayload: PayloadType {
    let meetingID: UInt64
    let date: String
    let time: String
    
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo) else { return nil }
        guard let meetingID = userInfo[UserInfoKey.meetingId.rawValue] as? UInt64,
              let date = userInfo[UserInfoKey.date.rawValue] as? String,
              let time = userInfo[UserInfoKey.time.rawValue] as? String
        else { return nil }
        self.meetingID = meetingID
        self.date = date
        self.time = time
        self._base = basePayload
    }
}
