//
//  CoreEvent.swift
//  Where
//
//  Created by Swain Yun on 4/18/25.
//

enum CoreEvent {
    // MARK: - Authentification Related
    case userDidLogin(id: UInt64)
    case userDidLogout(id: UInt64)
    
    // MARK: - Community Related
    case friendsListUpdated(meetingIDs: [UInt64: [UInt64]], summaries: [UInt64: MeetingSummary])
    
    // MARK: - Meeting Related
    
    
    // MARK: - Place Related
    
    
    // MARK: - Support Related
    
}
