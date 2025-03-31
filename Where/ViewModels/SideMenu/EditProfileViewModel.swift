//
//  EditProfileViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/25/25.
//

import SwiftUI
import Combine

final class EditProfileViewModel: ObservableObject {
    @Published var isPopupPresented: Bool = false
    @Published var profileImage: UIImage?
    @Published var nicknameFieldText: String = String()
    @Published var isNicknameValid: Bool = false
    
    private let auth: any AuthentificationCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(auth: any AuthentificationCoreProtocol) {
        self.auth = auth
        subscribe()
    }
    
    private func subscribe() {
        auth.user
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
#if DEBUG
                    print(error)
#endif
                }
            } receiveValue: { [weak self] user in
                self?.initializeProperties(user)
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

// MARK: Interfaces
extension EditProfileViewModel {
    func showPopup() {
        isPopupPresented = true
    }
}
