//
//  ProfileCreationViewModel.swift
//  Where
//
//  Created by Swain Yun on 5/2/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class ProfileCreationViewModel {
    private(set) var socialUser: User?
    private(set) var profileImageData: Data?
    private(set) var isProcessing: Bool = false
    private(set) var isErrorOccured: Bool = false
    private(set) var profileCreationStep: ProfileCreationStep = .profile
    private(set) var nicknameValidationState: NicknameValidationState = .beforeValidate
    
    private let authCore: AuthentificationCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.authentificationState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard case .registrationNeeded(let user) = state else { return }
                self?.socialUser = user
            }
            .store(in: cancellableBag, key: "AuthentificationState")
    }
}

// MARK: - Interfaces
extension ProfileCreationViewModel {
    func validateNickname(_ nickname: String) {
        guard nickname.isEmpty == false else {
            nicknameValidationState = .beforeValidate
            return
        }
        
        guard nickname.isValidNickname() else {
            nicknameValidationState = .invalid
            return
        }
        
        nicknameValidationState = .valid
    }
    
    func setImageData(_ data: Data?) {
        profileImageData = data
    }
    
    func setUpProfile(_ nickname: String) {
        isProcessing = true
        authCore.setUpProfile(nickname, profileImageData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isProcessing = false
                
                switch completion {
                case .finished:
                    self?.isErrorOccured = false
                    self?.profileCreationStep = .completed
                case .failure:
                    self?.isErrorOccured = true
                }
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
    }
}
