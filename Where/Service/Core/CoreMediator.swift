//
//  CoreMediator.swift
//  Where
//
//  Created by Swain Yun on 4/18/25.
//

import Foundation

typealias CoreMediatorProtocol = CoreLinkageProtocol & Notifiable

protocol CoreLinkageProtocol: AnyObject {
    func attachAuthentificationCore(_ core: AuthentificationMediationProtocol)
    func attachCommunityCore(_ core: CommunityMediationProtocol)
    func attachMeetingCore(_ core: MeetingMediationProtocol)
    func attachPlaceCore(_ core: PlaceMediationProtocol)
    func attachSupportCore(_ core: SupportMediationProtocol)
    func attachNotificationCore(_ core: NotificationMediationProtocol)
}

protocol Notifiable: AnyObject {
    func notify(event: CoreEvent)
}

final class CoreMediator {
    private var authentificationCore: AuthentificationMediationProtocol!
    private var communityCore: CommunityMediationProtocol!
    private var meetingCore: MeetingMediationProtocol!
    private var placeCore: PlaceMediationProtocol!
    private var supportCore: SupportMediationProtocol!
    private var notificationCore: NotificationMediationProtocol!
}

// MARK: - CoreLinkageProtocol Conformation
extension CoreMediator: CoreLinkageProtocol {
    func attachAuthentificationCore(_ core: AuthentificationMediationProtocol) {
        authentificationCore = core
    }
    
    func attachCommunityCore(_ core: CommunityMediationProtocol) {
        communityCore = core
    }
    
    func attachMeetingCore(_ core: MeetingMediationProtocol) {
        meetingCore = core
    }
    
    func attachPlaceCore(_ core: PlaceMediationProtocol) {
        placeCore = core
    }
    
    func attachSupportCore(_ core: SupportMediationProtocol) {
        supportCore = core
    }
    
    func attachNotificationCore(_ core: NotificationMediationProtocol) {
        notificationCore = core
    }
}

// MARK: - Notifiable Conformation
extension CoreMediator: Notifiable {
    func notify(event: CoreEvent) {
        switch event {
        case .userDidLogin(let user):
            communityCore.loadFriends(userID: user.id)
            
            // MARK: - MeetingCore Related
            meetingCore.setCurrentUser(user)
            meetingCore.loadAllMeetings()
            
            // MARK: - PlaceCore Related
            placeCore.setCurrentUserID(user.id)

            // MARK: - SupportCore Related
            supportCore.setCurrentUserID(user.id)
            supportCore.loadAnnouncements()
            supportCore.loadInquiries()
            
            // MARK: - NotificationCore Related
            notificationCore.setCurrentUserID(user.id)
            
        case .userDidLogout:
            communityCore.userDidLogout()
            meetingCore.userDidLogout()
            placeCore.userDidLogout()
            supportCore.userDidLogout()
            notificationCore.userDidLogout()
            
        case .friendsListUpdated(let meetingIDs, let summaries):
            meetingCore.updateRelatedMeetings(meetingIDs: meetingIDs, summaries: summaries)
        
        case .historyWithFriendWillUpdate(let friendID):
            meetingCore.loadCurrentMeetingsWithFriend(friendID: friendID)
        
        case .updateMeetingSchedule(let meeting):
            notificationCore.updateNotifications(for: meeting)
        
        case .removeNotification(let id):
            notificationCore.removeNotifications(for: id)
            
        case .inAppMeetingInvitation(let inviterName, let meeting):
            meetingCore.perfomInAppMeetingInvitation(inviterName: inviterName, meeting: meeting)
        case .applicationDidLaunch:
            authentificationCore.loadCurrentUser()
            supportCore.loadAnnouncements()
            
        case .fcmTokenUpdated(let fcmToken):
            authentificationCore.fcmTokenUpdated(fcmToken)
        }
    }
}
