//
//  MeetingInvitationStatus.swift
//  Where
//
//  Created by BOMBSGIE on 4/25/25.
//

import Foundation

struct MeetingInvitationState {
    let hostID: UInt64
    let hostName: String
    let guestID: UInt64
    let guestName: String
    var isInvited: Bool
    var isAccepted: Bool
    let guestImageURL: URL?
    
    init(
        hostID: UInt64,
        hostName: String,
        guestID: UInt64,
        guestName: String,
        isInvited: Bool,
        isAccepted: Bool,
        guestImageURLString: String?
    ) {
        self.hostID = hostID
        self.hostName = hostName
        self.guestID = guestID
        self.guestName = guestName
        self.isInvited = isInvited
        self.isAccepted = isAccepted
        self.guestImageURL = URL(string: guestImageURLString ?? "")
    }
}
