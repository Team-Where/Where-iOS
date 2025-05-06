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
    
    @Published private(set) var nicknameValidationState: NicknameValidationState = .beforeValidate
    @Published private(set) var profileCreationStep: ProfileCreationStep = .profile
    
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
    private var cancellables = Set<AnyCancellable>()
    
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
                
                // TODO: 닉네임 중복 검사
                
                
                self?.nicknameValidationState = .valid
            }
            .store(in: &cancellables)
        
        authCore.authentificationState
            .receive(on: DispatchQueue.main)
            .sink { completion in
                //
            } receiveValue: { [weak self] state in
                guard case .registrationNeeded(let user) = state else { return }
                self?.socialUser = user
            }
            .store(in: &cancellables)
    }
    
    private func setUpProfile(_ user: User) {
        let imageUpdatePublisher: AnyPublisher<Void, AuthentificationCoreError>
        
        if let data = profileImageData {
            // 사용자가 새로운 이미지를 선택한 경우
            if user.imageURL != nil {
                // 소셜 로그인으로 프로필사진이 있는 경우 -> 이미지 변경
                imageUpdatePublisher = authCore.updateUserProfile(profileImageData: data)
                    .map { _ in () }
                    .eraseToAnyPublisher()
            } else {
                // 소셜 로그인으로 프로필사진이 없는 경우 -> 이미지 등록
                imageUpdatePublisher = authCore.createUserProfile(profileImageData: data)
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
        } else if user.imageURL != nil {
            // 사용자가 새로운 이미지를 선택하지 않았지만 소셜 로그인으로 프로필사진이 있는 경우 -> 이미지 삭제
            imageUpdatePublisher = authCore.deleteUserProfile()
                .map { _ in () }
                .eraseToAnyPublisher()
        } else {
            // 새로운 이미지도 선택하지 않았고, 소셜 로그인으로도 프로필사진이 없는 경우 -> 별도 작업은 필요 없음
            imageUpdatePublisher = Just(()).setFailureType(to: AuthentificationCoreError.self).eraseToAnyPublisher()
        }
        
        let nicknameUpdatePublisher = authCore.updateNickname(nicknameFieldText)
        
        // 프로필사진 설정과 닉네임 설정을 같이 요청한 뒤 결과 반영
        imageUpdatePublisher
            .combineLatest(nicknameUpdatePublisher)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] _ in
                self?.profileCreationStep = .completed
            }
            .store(in: &cancellables)
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
