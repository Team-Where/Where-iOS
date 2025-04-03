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
            guard let auth = resolver.resolve(AuthentificationCoreProtocol.self) else {
                fatalError("AuthentificationCoreProtocol not registered")
            }
            return SideMenuContentViewModel(auth: auth)
        }
        container.register(HomeViewModel.self) { resolver in
            guard let community = resolver.resolve((any CommunityCoreProtocol).self) else {
                fatalError("CommunityCoreProtocol not registered")
            }
            return HomeViewModel(community: community)
        }
        container.register(MeetingInformationDetailViewModel.self) { resolver in
            guard let community = resolver.resolve(CommunityCoreProtocol.self) else {
                fatalError("CommunityCoreProtocol not registered")
            }
            return MeetingInformationDetailViewModel(community: community)
        }
    }
}
