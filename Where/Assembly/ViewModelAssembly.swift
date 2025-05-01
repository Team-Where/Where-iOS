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
            return LoginViewModel(resolver: resolver)
        }
        
        container.register(SignInViewModel.self) { resolver in
            return SignInViewModel(resolver: resolver)
        }
        
        container.register(RegistrationViewModel.self) { resolver in
            return RegistrationViewModel(resolver: resolver)
        }
        
        container.register(EditProfileViewModel.self) { resolver in
            return EditProfileViewModel(resolver: resolver)
        }
        
        container.register(SideMenuContentViewModel.self) { resolver in
            return SideMenuContentViewModel(resolver: resolver)
        }
        
        container.register(MyMeetingViewModel.self) { resolver in
            return MyMeetingViewModel(resolver: resolver)
        }
        
        container.register(MeetingInformationDetailViewModel.self) { resolver in
            return MeetingInformationDetailViewModel(resolver: resolver)
        }
        
        container.register(MeetingInformationViewModel.self) { resolver in
            return MeetingInformationViewModel(resolver: resolver)
        }
        
        container.register(FriendsListViewModel.self) { resolver in
            return FriendsListViewModel(resolver: resolver)
        }
        
        container.register(CreateMeetingViewModel.self) { resolver in
            return CreateMeetingViewModel(resolver: resolver)
        }
        
        container.register(InviteFriendsViewModel.self) { resolver in
            return InviteFriendsViewModel(resolver: resolver)
        }
        
        container.register(MeetingPlacesViewModel.self) { resolver in
            return MeetingPlacesViewModel(resolver: resolver)
        }
        
        container.register(PlaceDetailViewModel.self) { resolver in
            return PlaceDetailViewModel(resolver: resolver)
        }
        
        container.register(CommentViewModel.self) { resolver in
            return CommentViewModel(resolver: resolver)
        }
        
        container.register(UnregisterViewModel.self) { resolver in
            return UnregisterViewModel(resolver: resolver)
        }
        
        container.register(FAQViewModel.self) { resolver in
            return FAQViewModel(resolver: resolver)
        }
        
        container.register(EditInquiryViewModel.self) { resolver in
            return EditInquiryViewModel(resolver: resolver)
        }
        
        container.register(InquiryViewModel.self) { resolver in
            return InquiryViewModel(resolver: resolver)
        }
        
        container.register(PreferenceViewModel.self) { resolver in
            return PreferenceViewModel(resolver: resolver)
        }
        
        container.register(ContentViewModel.self) { resolver in
            return ContentViewModel(resolver: resolver)
        }
        
        container.register(ProfileCreationViewModel.self) { resolver in
            return ProfileCreationViewModel(resolver: resolver)
        }
    }
}
