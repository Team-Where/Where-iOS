//
//  AuthAssembly.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import Foundation
import Swinject

struct CoreAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(AuthentificationCore.self) { resolver in
            guard let apiService = resolver.resolve(APIServable.self)
            else {
                fatalError("Failed Initializing AuthentificationCore")
            }
            return AuthentificationCore(apiService: apiService)
        }
        .inObjectScope(.container)
        .initCompleted { resolver, core in
            guard let mediator = resolver.resolve(CoreMediatorProtocol.self) else {
                fatalError("CoreMediatorProtocol not registered")
            }
            core.mediator = mediator
        }
        
        container.register(AuthentificationCoreProtocol.self) { resolver in
            guard let core = resolver.resolve(AuthentificationCore.self) else {
                fatalError("AuthentificationCore concrete type not resolvable")
            }
            return core
        }
        
        container.register(AuthentificationMediationProtocol.self) { resolver in
            guard let core = resolver.resolve(AuthentificationCore.self) else {
                fatalError("AuthentificationCore concrete type not resolvable")
            }
            return core
        }
        
        container.register(CommunityCore.self) { resolver in
            guard let apiService = resolver.resolve(APIServable.self)
            else {
                fatalError("Failed Initializing CommunityCore")
            }
            return CommunityCore(apiService: apiService)
        }
        .inObjectScope(.container)
        .initCompleted { resolver, core in
            guard let mediator = resolver.resolve(CoreMediatorProtocol.self) else {
                fatalError("CoreMediatorProtocol not registered")
            }
            core.mediator = mediator
        }
        
        container.register(CommunityCoreProtocol.self) { resolver in
            guard let core = resolver.resolve(CommunityCore.self) else {
                fatalError("CommunityCore concrete type not resolvable")
            }
            return core
        }
        
        container.register(CommunityMediationProtocol.self) { resolver in
            guard let core = resolver.resolve(CommunityCore.self) else {
                fatalError("CommunityCore concrete type not resolvable")
            }
            return core
        }
        
        container.register(MeetingCore.self) { resolver in
            guard let encoder = resolver.resolve(JSONEncoder.self),
                  let apiService = resolver.resolve(APIServable.self)
            else {
                fatalError("Failed Initializing MeetingCore")
            }
            return MeetingCore(apiService: apiService, encoder: encoder)
        }
        .inObjectScope(.container)
        .initCompleted { resolver, core in
            guard let mediator = resolver.resolve(CoreMediatorProtocol.self) else {
                fatalError("CoreMediatorProtocol not registered")
            }
            core.mediator = mediator
        }
        
        container.register(MeetingCoreProtocol.self) { resolver in
            guard let core = resolver.resolve(MeetingCore.self) else {
                fatalError("MeetingCore concrete type not resolvable")
            }
            return core
        }
        
        container.register(MeetingMediationProtocol.self) { resolver in
            guard let core = resolver.resolve(MeetingCore.self) else {
                fatalError("MeetingCore concrete type not resolvable")
            }
            return core
        }
        
        container.register(PlaceCore.self) { resolver in
            guard let apiService = resolver.resolve(APIServable.self)
            else {
                fatalError("Failed Initializing PlaceCore")
            }
            return PlaceCore(apiService: apiService)
        }
        .inObjectScope(.container)
        .initCompleted { resolver, core in
            guard let mediator = resolver.resolve(CoreMediatorProtocol.self) else {
                fatalError("CoreMediatorProtocol not registered")
            }
            core.mediator = mediator
        }
        
        container.register(PlaceCoreProtocol.self) { resolver in
            guard let core = resolver.resolve(PlaceCore.self) else {
                fatalError("PlaceCore concrete type not resolvable")
            }
            return core
        }
        
        container.register(PlaceMediationProtocol.self) { resolver in
            guard let core = resolver.resolve(PlaceCore.self) else {
                fatalError("PlaceCore concrete type not resolvable")
            }
            return core
        }
        
        container.register(SupportCore.self) { resolver in
            guard let apiService = resolver.resolve(APIServable.self),
                  let encoder = resolver.resolve(JSONEncoder.self)
            else {
                fatalError("TokenStorageProtocol not registered")
            }
            return SupportCore(encoder: encoder, apiService: apiService)
        }
        .inObjectScope(.container)
        .initCompleted { resolver, core in
            guard let mediator = resolver.resolve(CoreMediatorProtocol.self) else {
                fatalError("CoreMediatorProtocol not registered")
            }
            core.mediator = mediator
        }
        
        container.register(SupportCoreProtocol.self) { resolver in
            guard let core = resolver.resolve(SupportCore.self) else {
                fatalError("SupportCore concrete type not resolvable")
            }
            return core
        }
        
        container.register(SupportMediationProtocol.self) { resolver in
            guard let core = resolver.resolve(SupportCore.self) else {
                fatalError("SupportCore concrete type not resolvable")
            }
            return core
        }
        
        container.register(CoreMediatorProtocol.self) { _ in
            return CoreMediator()
        }
        .inObjectScope(.container)
        .initCompleted { resolver, mediator in
            guard let authentificationCore = resolver.resolve(AuthentificationMediationProtocol.self),
                  let communityCore = resolver.resolve(CommunityMediationProtocol.self),
                  let meetingCore = resolver.resolve(MeetingMediationProtocol.self),
                  let placeCore = resolver.resolve(PlaceMediationProtocol.self),
                  let supportCore = resolver.resolve(SupportMediationProtocol.self)
            else {
                fatalError("Major cores are not registered")
            }
            mediator.attachAuthentificationCore(authentificationCore)
            mediator.attachCommunityCore(communityCore)
            mediator.attachMeetingCore(meetingCore)
            mediator.attachPlaceCore(placeCore)
            mediator.attachSupportCore(supportCore)
        }
    }
}
