//
//  ScheduleDeletedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct ScheduleDeletedPayload: PayloadType {
    let meetingID: UInt64
    let _base: BasePayload
    
    init?(userInfo: [AnyHashable : Any]) {
        guard let basePayload = BasePayload(userInfo: userInfo) else { return nil }
        guard let meetingID = userInfo[UserInfoKey.meetingId.rawValue] as? UInt64 else { return nil }
        
        self.meetingID = meetingID
        self._base = basePayload
    }
}
