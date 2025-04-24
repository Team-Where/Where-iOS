//
//  CoreEvent.swift
//  Where
//
//  Created by Swain Yun on 4/18/25.
//

enum CoreEvent {
    // MARK: - Authentification Related
    case userDidLogin(id: UInt64, isAdmin: Bool)
    case userDidLogout(id: UInt64)
    
    // MARK: - Community Related
    case friendsListUpdated(meetingIDs: [UInt64: [UInt64]], summaries: [UInt64: MeetingSummary])
    case historyWithFriendWillUpdate(friendID: UInt64)
    
    // MARK: - Meeting Related
    
    
    // MARK: - Place Related
    
    
    // MARK: - Support Related
    
}
