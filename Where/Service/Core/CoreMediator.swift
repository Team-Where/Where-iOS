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
        case .userDidLogin(let user, let isAdmin):
            communityCore.loadFriends(userID: user.id)
            
            // MARK: - MeetingCore Related
            meetingCore.setCurrentUser(user)
            meetingCore.loadAllMeetings()

            // MARK: - SupportCore Related
            supportCore.setCurrentUserID(user.id)
            supportCore.loadAnnouncements()
            isAdmin ? supportCore.loadAdminInquiries() : supportCore.loadInquiries()
        case .userDidLogout(let userID):
            // TODO: 로그 아웃 처리
            return
            
        case .friendsListUpdated(let meetingIDs, let summaries):
            meetingCore.updateRelatedMeetings(meetingIDs: meetingIDs, summaries: summaries)
        case .historyWithFriendWillUpdate(let friendID):
            meetingCore.loadCurrentMeetingsWithFriend(friendID: friendID)
            
            
            
            
        case .currentMeetingWillUpdate(let meetingID):
            placeCore.loadPlaces(meetingID: meetingID)
        }
    }
}
