//
//  ProfileCreationViewModel.swift
//  Where
//
//  Created by Swain Yun on 5/2/25.
//

import Foundation
import Combine
import Swinject

final class ProfileCreationViewModel: ObservableObject {
    @Published var profileImageData: Data?
    @Published var nicknameFieldText: String = String()
    @Published var isPopupPresented: Bool = false
    @Published var isCompleted: Bool = false
    
    var navigationTitle: String {
        switch profileCreationStep {
        case .profile:
            "프로필을 설정해주세요"
        case .completed:
            "\(nicknameFieldText)님,\n회원가입을 축하합니다!"
        }
    }
    
    var isProceedButtonDisabled: Bool {
        switch profileCreationStep {
        case .profile: return nicknameValidationState != .valid
        case .completed: return true
        }
    }
    
    var proceedButtonLabel: String {
        profileCreationStep == .completed ? "완료" : "다음"
    }
    
    var nicknameValidationNotice: String {
        switch nicknameValidationState {
        case .valid: "사용 가능한 닉네임입니다."
        case .invalid, .beforeValidate: "2~8자의 영문, 숫자, 한글, 특수문자(-, _)만 사용할 수 있습니다."
        case .duplicated: "이미 사용 중인 닉네임입니다."
        }
    }
    
    private(set) var nicknameValidationState: NicknameValidationState = .beforeValidate
    private(set) var profileCreationStep: ProfileCreationStep = .profile
    
    private let authCore: AuthentificationCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
    }
    
    private func subscribe() {
        $nicknameFieldText
            .removeDuplicates()
            .sink { [weak self] nickname in
                guard nickname.isEmpty == false else {
                    self?.nicknameValidationState = .beforeValidate
                    return
                }
                
                guard nickname.isValidNickname() else {
                    self?.nicknameValidationState = .invalid
                    return
                }
                
                // TODO: 닉네임 중복 검사
                
                
                self?.nicknameValidationState = .valid
            }
            .store(in: &cancellables)
    }
}

// MARK: - Interfaces
extension ProfileCreationViewModel {
    func proceed() {
        guard isProceedButtonDisabled == false else { return }
        
        switch profileCreationStep {
        case .profile: profileCreationStep = .completed
        case .completed: isCompleted = true
        }
    }
}
