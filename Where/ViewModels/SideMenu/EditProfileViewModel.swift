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
    @Published var nicknameFieldText: String
    @Published var isNicknameValid: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(user: User) {
        defer { subscribe() }
        
        guard let imageURL = user.imageURL,
              let data = try? Data(contentsOf: imageURL),
              let image = UIImage(data: data)
        else {
            self.profileImage = UIImage(named: "person")
            self.nicknameFieldText = user.nickname
            return
        }
        
        self.profileImage = image
        self.nicknameFieldText = user.nickname
    }
    
    private func subscribe() {
        $nicknameFieldText
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nickname in
                self?.isNicknameValid = nickname.isValidNickname()
            }
            .store(in: &cancellables)
    }
}

// MARK: Interfaces
extension EditProfileViewModel {
    func showPopup() {
        isPopupPresented = true
    }
}
