//
//  EditProfileViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/25/25.
//

import SwiftUI
import Combine
import Swinject

final class EditProfileViewModel: ObservableObject {
    @Published var isPopupPresented: Bool = false
    @Published var profileImage: UIImage?
    @Published var nicknameFieldText: String = String()
    @Published var isNicknameValid: Bool = false
    @Published var step: EditProfileStep = .beforeUpdate
    @Published var isFloaterPresented: Bool = false
    
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
                self?.initializeProperties(user)
                self?.step = .done
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
    
    private func initializeProperties(_ user: User?) {
        guard let imageURL = user?.imageURL,
              let data = try? Data(contentsOf: imageURL),
              let image = UIImage(data: data)
        else {
            self.profileImage = UIImage(named: "person")
            self.nicknameFieldText = user?.nickname ?? ""
            return
        }
        
        self.profileImage = image
        self.nicknameFieldText = user?.nickname ?? ""
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
        step = .processing
        
        // TODO: 프로필 수정 기능 연결
    }
}
