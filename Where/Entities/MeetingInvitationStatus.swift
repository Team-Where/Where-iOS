//
//  MeetingInvitationStatus.swift
//  Where
//
//  Created by BOMBSGIE on 4/25/25.
//

import Foundation

struct MeetingInvitationStatus {
    let hostID: UInt64
    let hostName: String
    let guestID: UInt64
    let guestName: String
    var status: Bool
    let hostImageURLString: URL?
    
    init(
        hostID: UInt64,
        hostName: String,
        guestID: UInt64,
        guestName: String,
        status: Bool,
        hostImageURLString: String?
    ) {
        self.hostID = hostID
        self.hostName = hostName
        self.guestID = guestID
        self.guestName = guestName
        self.status = status
        self.hostImageURLString = URL(string: hostImageURLString ?? "")
    }
}
