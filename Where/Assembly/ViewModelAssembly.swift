//
//  ViewModelAssembly.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import Foundation
import Swinject

@MainActor
struct ViewModelAssembly: @preconcurrency Assembly {
    func assemble(container: Container) {
        container.register(LoginViewModel.self) { resolver in
            guard let auth = resolver.resolve(AuthentificationCoreProtocol.self) else {
                fatalError("AuthentificationCoreProtocol not registered")
            }
            return LoginViewModel(auth: auth)
        }
        container.register(SignInViewModel.self) { resolver in
            guard let auth = resolver.resolve(AuthentificationCoreProtocol.self) else {
                fatalError("AuthentificationCoreProtocol not registered")
            }
            return SignInViewModel(auth: auth)
        }
        container.register(RegistrationViewModel.self) { resolver in
            guard let auth = resolver.resolve(AuthentificationCoreProtocol.self) else {
                fatalError("AuthentificationCoreProtocol not registered")
            }
            return RegistrationViewModel(auth: auth)
        }
        container.register(EditProfileViewModel.self) { resolver in
            guard let auth = resolver.resolve(AuthentificationCoreProtocol.self) else {
                fatalError("AuthentificationCoreProtocol not registered")
            }
            return EditProfileViewModel(auth: auth)
        }
        container.register(SideMenuContentViewModel.self) { resolver in
            guard let authCore = resolver.resolve(AuthentificationCoreProtocol.self),
                  let meetingCore = resolver.resolve(MeetingCoreProtocol.self)
            else {
                fatalError("AuthentificationCoreProtocol, MeetingCoreProtocol not registered")
            }
            return SideMenuContentViewModel(authCore: authCore, meetingCore: meetingCore)
        }
        container.register(MyMeetingViewModel.self) { resolver in
            guard let meetingCore = resolver.resolve(MeetingCoreProtocol.self) else {
                fatalError("MeetingCoreProtocol not registered")
            }
            return MyMeetingViewModel(meetingCore: meetingCore)
        }
        container.register(MeetingInformationDetailViewModel.self) { resolver in
            guard let communityCore = resolver.resolve(CommunityCoreProtocol.self),
                  let meetingCore = resolver.resolve(MeetingCoreProtocol.self)
            else {
                fatalError("CommunityCoreProtocol and MeetingCoreProtocol not registered")
            }
            return MeetingInformationDetailViewModel(communityCore: communityCore, meetingCore: meetingCore)
        }
        container.register(FriendsListViewModel.self) { resolver in
            guard let communityCore = resolver.resolve(CommunityCoreProtocol.self) else {
                fatalError("CommunityCoreProtocol not registered")
            }
            return FriendsListViewModel(communityCore: communityCore)
        }
        container.register(CreateMeetingViewModel.self) { resolver in
            guard let communityCore = resolver.resolve(CommunityCoreProtocol.self),
                  let meetingCore = resolver.resolve(MeetingCoreProtocol.self)
            else {
                fatalError("CommunityCoreProtocol, MeetingCoreProtocol not registered")
            }
            return CreateMeetingViewModel(communityCore: communityCore, meetingCore: meetingCore)
        }
        container.register(InviteFriendsViewModel.self) { resolver in
            guard let communityCore = resolver.resolve(CommunityCoreProtocol.self) else {
                fatalError("CommunityCoreProtocol not registered")
            }
            return InviteFriendsViewModel(communityCore: communityCore)
        }
        container.register(MeetingPlacesViewModel.self) { resolver in
            guard let placeCore = resolver.resolve(PlaceCoreProtocol.self) else {
                fatalError("PlaceCoreProtocol not registered")
            }
            return MeetingPlacesViewModel(placeCore: placeCore)
        }
        container.register(PlaceDetailViewModel.self) { resolver in
            guard let placeCore = resolver.resolve(PlaceCoreProtocol.self) else {
                fatalError("PlaceCoreProtocol not registered")
            }
            return PlaceDetailViewModel(placeCore: placeCore)
        }
        container.register(CommentViewModel.self) { resolver in
            guard let placeCore = resolver.resolve(PlaceCoreProtocol.self) else {
                fatalError("PlaceCoreProtocol not registered")
            }
            return CommentViewModel(placeCore: placeCore)
        }
    }
}
