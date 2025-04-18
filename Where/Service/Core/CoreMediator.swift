//
//  CoreMediator.swift
//  Where
//
//  Created by Swain Yun on 4/18/25.
//

import Foundation

typealias CoreMediatorProtocol = CoreLinkageProtocol & Notifiable

protocol CoreLinkageProtocol: AnyObject {
    func attachAuthentificationCore(_ core: AuthentificationCoreProtocol)
    func attachCommunityCore(_ core: CommunityCoreProtocol)
    func attachMeetingCore(_ core: MeetingCoreProtocol)
    func attachPlaceCore(_ core: PlaceCoreProtocol)
    func attachSupportCore(_ core: SupportCoreProtocol)
    func attachNotificationCore(_ core: NotificationCoreProtocol)
}

protocol Notifiable: AnyObject {
    func notify(event: CoreEvent)
}

final class CoreMediator {
    private var authentificationCore: AuthentificationCoreProtocol!
    private var communityCore: CommunityCoreProtocol!
    private var meetingCore: MeetingCoreProtocol!
    private var placeCore: PlaceCoreProtocol!
    private var supportCore: SupportCoreProtocol!
    private var notificationCore: NotificationCoreProtocol!
}

// MARK: - CoreLinkageProtocol Conformation
extension CoreMediator: CoreLinkageProtocol {
    func attachAuthentificationCore(_ core: AuthentificationCoreProtocol) {
        authentificationCore = core
    }
    
    func attachCommunityCore(_ core: CommunityCoreProtocol) {
        communityCore = core
    }
    
    func attachMeetingCore(_ core: MeetingCoreProtocol) {
        meetingCore = core
    }
    
    func attachPlaceCore(_ core: PlaceCoreProtocol) {
        placeCore = core
    }
    
    func attachSupportCore(_ core: SupportCoreProtocol) {
        supportCore = core
    }
    
    func attachNotificationCore(_ core: NotificationCoreProtocol) {
        notificationCore = core
    }
}

// MARK: - Notifiable Conformation
extension CoreMediator: Notifiable {
    func notify(event: CoreEvent) {
        // TODO: 이벤트별 로직 추가
    }
}
