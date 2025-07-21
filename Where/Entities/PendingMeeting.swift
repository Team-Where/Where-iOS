//
//  PendingMeeting.swift
//  Where
//
//  Created by BOMBSGIE on 7/22/25.
//

import Foundation

struct PendingMeeting {
    let inviteID: UInt64
    let meetingID: UInt64
    let meetingImageURL: URL?
    let hostNickname: String
    let meetingTitle: String
    let scheduleDate: Date?
    let scheduleTime: Date?
}
