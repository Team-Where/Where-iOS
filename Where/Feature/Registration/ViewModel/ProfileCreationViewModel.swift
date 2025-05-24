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
    @Published var socialUser: User?
    @Published var isFloaterPresented: Bool = false
    
    @Published private(set) var nicknameValidationState: NicknameValidationState = .beforeValidate
    @Published private(set) var profileCreationStep: ProfileCreationStep = .profile
    @Published private(set) var isProcessing: Bool = false
    
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
    
    private let authCore: AuthentificationCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        subscribe()
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
                
                // TODO: 닉네임 중복 검사 (WIP)
                
                
                self?.nicknameValidationState = .valid
            }
            .store(in: cancellableBag, key: "NicknameFieldText")
        
        authCore.authentificationState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard case .registrationNeeded(let user) = state else { return }
                self?.socialUser = user
            }
            .store(in: cancellableBag, key: "AuthentificationState")
    }
    
    private func setUpProfile(_ user: User) {
        let imageUpdatePublisher = Just((profileImageData, user.imageURL))
            .flatMap { [authCore] (data, url) -> AnyPublisher<Void, AuthentificationCoreError> in
                switch (data, url) {
                case (.some(let data), .some):
                    // 새로운 이미지가 있고, 기존 프로필 사진이 있는 경우 -> 이미지 변경
                    return authCore.updateUserProfile(profileImageData: data)
                    
                case (.some(let data), .none):
                    // 새로운 이미지가 있고, 기존 프로필 사진이 없는 경우 -> 이미지 등록
                    return authCore.createUserProfile(profileImageData: data)
                    
                case (.none, .some):
                    // 새로운 이미지가 없고, 기존 프로필 사진이 있는 경우 -> 이미지 삭제
                    return authCore.deleteUserProfile()
                    
                case (.none, .none):
                    // 새로운 이미지가 없고, 기존 프로필 사진도 없는 경우 -> 별도 작업 없음
                    return Empty(outputType: Void.self, failureType: AuthentificationCoreError.self).eraseToAnyPublisher()
                }
            }
        
        let nicknameUpdatePublisher = authCore.updateNickname(nicknameFieldText)
        
        isProcessing = true
        cancellableBag[#function] = imageUpdatePublisher
            .combineLatest(nicknameUpdatePublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isProcessing = false
                
                switch completion {
                case .finished: self?.profileCreationStep = .completed
                case .failure: self?.isFloaterPresented = true
                }
            } receiveValue: { _ in }
    }
}

// MARK: - Interfaces
extension ProfileCreationViewModel {
    func proceed() {
        guard isProceedButtonDisabled == false else { return }
        
        switch profileCreationStep {
        case .profile:
            guard let user = socialUser else { return }
            setUpProfile(user)
            
        case .completed:
            isCompleted = true
        }
    }
}
