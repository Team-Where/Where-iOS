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
}
