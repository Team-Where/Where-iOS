//
//  EditProfileViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/25/25.
//

import Foundation
import Combine
import Swinject

@MainActor
final class EditProfileViewModel: ObservableObject {
    @Published var isPopupPresented: Bool = false
    @Published var profileImageData: Data?
    @Published var nicknameFieldText: String = String()
    @Published var isNicknameValid: Bool = false
    @Published var step: EditProfileStep = .beforeUpdate
    @Published var isFloaterPresented: Bool = false
    
    private(set) var currentUser: User?
    
    private let authCore: AuthentificationCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.step = .errorOccured
#if DEBUG
                    print(error)
#endif
                }
            } receiveValue: { [weak self] user in
                guard let user else { return }
                self?.nicknameFieldText = user.nickname ?? String()
            }
            .store(in: &cancellables)
        
        $nicknameFieldText
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.isNicknameValid = nickname.isValidNickname()
            }
            .store(in: &cancellables)
    }
}

// MARK: Nested Types
extension EditProfileViewModel {
    /// 프로필 수정 단계
    enum EditProfileStep {
        /// 프로필 수정 요청 전
        case beforeUpdate
        /// 프로필 수정 진행 중
        case processing
        /// 프로필 수정 완료
        case done
        /// 프로필 수정 실패
        case errorOccured
    }
}

// MARK: Interfaces
extension EditProfileViewModel {
    func showPopup() {
        isPopupPresented = true
    }
    
    func updateProfile() {
        guard step != .processing else { return }
        
        guard let user = currentUser else { return step = .errorOccured }
        
        step = .processing
        
        guard let user = currentUser else {
            return step = .errorOccured
        }
        
        let imageUpdatePublisher: AnyPublisher<Void, AuthentificationCoreError>
        
        if let data = profileImageData {
            if user.imageURL != nil {
                // 기존 프로필사진이 있는 경우 -> 프로필 변경
                imageUpdatePublisher = authCore.updateUserProfile(profileImageData: data)
                    .map { _ in () }
                    .eraseToAnyPublisher()
            } else {
                // 기존 프로필사진이 없는 경우 -> 프로필 등록
                imageUpdatePublisher = authCore.createUserProfile(profileImageData: data)
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
        } else {
            if user.imageURL != nil {
                // 기존 프로필사진이 있는 경우 -> 프로필 삭제
                imageUpdatePublisher = authCore.deleteUserProfile()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            } else {
                // 기존 프로필사진도 없고, 선택한 이미지도 없을 경우 -> 별도 처리 필요 없음
                imageUpdatePublisher = Just(()).setFailureType(to: AuthentificationCoreError.self).eraseToAnyPublisher()
            }
        }
        
        let nicknameUpdatePublisher = authCore.updateNickname(nicknameFieldText)
        
        imageUpdatePublisher
            .combineLatest(nicknameUpdatePublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.step = .done
                case .failure(let error):
                    self?.isFloaterPresented = true
                }
            } receiveValue: { (_, isDone) in
                return
            }
            .store(in: &cancellables)
    }
    
    func selectProfileImageData(_ data: Data?) {
        profileImageData = data
    }
}
