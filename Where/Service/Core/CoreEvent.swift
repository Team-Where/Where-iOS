//
//  CoreEvent.swift
//  Where
//
//  Created by Swain Yun on 4/18/25.
//

import Foundation

enum CoreEvent {
    // MARK: - Authentification Related
    case userDidLogin(id: UInt64)
    case userDidLogout(id: UInt64)
    
    // MARK: - Community Related
    case friendListUpdated(id: UInt64)
    case friendSelected(id: UInt64)
    
    // MARK: - Meeting Related
    case meetingCreated(id: UInt64)
    case meetingUpdated(id: UInt64)
    case currentMeetingDidChange(id: UInt64)
    case participantListUpdated(id: UInt64)
    case meetingSelected(id: UInt64)
    
    // MARK: - Place Related
    case placeSelected(id: UInt64)
    case placeCreated(meetingID: UInt64, id: UInt64)
    case commentCreated(placeID: UInt64, id: UInt64)
    
    // MARK: - Support Related
    case inquiryCreated(userID: UInt64, id: UInt64)
    case adminInquiryReplyCreated(id: UInt64, replyID: UInt64)
    case announcementCreated(id: UInt64)
    case announcementUpdated(id: UInt64)
    case announcementDeleted(id: UInt64)
    case faqCreated(id: UInt64)
    case faqUpdated(id: UInt64)
    case faqDeleted(id: UInt64)
}
