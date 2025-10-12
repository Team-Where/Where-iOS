//
//  EditProfileViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/25/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class EditProfileViewModel {
    private(set) var step: EditProfileStep = .beforeUpdate
    private(set) var currentUser: User?
    
    private let authCore: AuthentificationCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: cancellableBag, key: "CurrentUser")
    }
}

// MARK: Nested Types
extension EditProfileViewModel {
    /// 프로필 수정 단계
    enum EditProfileStep: Equatable {
        /// 프로필 수정 요청 전
        case beforeUpdate
        /// 프로필 수정 진행 중
        case processing
        /// 프로필 수정 완료
        case done
        /// 프로필 수정 실패
        case errorOccured(AuthentificationCoreError)
        
        static func == (lhs: EditProfileViewModel.EditProfileStep, rhs: EditProfileViewModel.EditProfileStep) -> Bool {
            String(describing: lhs) == String(describing: rhs)
        }
    }
}

// MARK: Interfaces
extension EditProfileViewModel {
    func updateProfile(nickname: String, profileImageData: Data?) {
        guard step != .processing else { return }
        
        guard let user = currentUser else { return step = .errorOccured(.userInfoFetchFailed) }
        
        step = .processing
        
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
        
        let nicknameUpdatePublisher = authCore.updateNickname(nickname)
        
        imageUpdatePublisher
            .combineLatest(nicknameUpdatePublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.step = .done
                case .failure(let error):
                    self?.step = .errorOccured(error)
                }
            } receiveValue: { (_, isDone) in
                return
            }
            .store(in: cancellableBag, key: #function)
    }
}
