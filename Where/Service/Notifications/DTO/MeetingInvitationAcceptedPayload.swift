//
//  MeetingInvitationAcceptedPayload.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

struct MeetingInvitationAcceptedPayload {
    
    let meetingID: UInt64
    let userID: UInt64
    let hostName: String
    let hostImage: String?
}
