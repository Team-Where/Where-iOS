//
//  CoreEvent.swift
//  Where
//
//  Created by Swain Yun on 4/18/25.
//

enum CoreEvent {
    // MARK: - Authentification Related
    case userDidLogin(user: User)
    case userDidLogout
    
    // MARK: - Community Related
    case friendsListUpdated(meetingIDs: [UInt64: [UInt64]], summaries: [UInt64: MeetingSummary])
    case historyWithFriendWillUpdate(friendID: UInt64)
    
    // MARK: - Meeting Related
    case updateMeetingSchedule(meeting: Meeting)
    case removeNotification(id: UInt64)
    
    // MARK: - Place Related
    case currentMeetingWillUpdate(meetingID: UInt64)
    
    // MARK: - Support Related
    
    
    // MARK: - Notification Related
    
    
    // MARK: - Common
    case applicationDidLaunch
}
