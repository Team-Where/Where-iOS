//
//  AdjustPasswordViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/22/25.
//

import Foundation
import Combine

final class AdjustPasswordViewModel: ObservableObject {
    @Published var passwordFieldText: String = String()
    @Published var reInputPasswordFieldText: String = String()
    
    @Published var passwordValidationState: PasswordValidationState = .beforeValidate
    @Published var passwordComparisonResult: PasswordComparisonResult = .unknown
    
    var isDoneButtomDisabled: Bool {
        (passwordValidationState == .valid && passwordComparisonResult == .same) == false
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    private func subscribe() {
        $passwordFieldText
            .removeDuplicates()
            .sink { [weak self] password in
                guard password.isEmpty == false else {
                    self?.passwordValidationState = .beforeValidate
                    return
                }
                
                guard self?.isPasswordValid(password) ?? false else {
                    self?.passwordValidationState = .invalid
                    return
                }
                
                self?.passwordValidationState = .valid
            }
            .store(in: &cancellables)
        
        $reInputPasswordFieldText
            .removeDuplicates()
            .sink { [weak self] password in
                guard password.isEmpty == false else {
                    self?.passwordComparisonResult = .unknown
                    return
                }
                
                guard self?.passwordFieldText == password else {
                    self?.passwordComparisonResult = .different
                    return
                }
                
                self?.passwordComparisonResult = .same
            }
            .store(in: &cancellables)
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
        // 8~32자
        guard (8...32).contains(password.count) else { return false }
        
        // 영문, 숫자, 특수문자("!", "~", "@") 포함
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigits = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecialCharacters = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!~@")) != nil
        
        return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters
    }
}
