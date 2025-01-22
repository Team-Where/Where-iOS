//
//  AthentificationViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/21/25.
//

import Foundation
import Combine

@MainActor
final class AthentificationViewModel: ObservableObject {
    @Published var emailFieldText: String = String()
    @Published var authorizationCodeFieldText: String = String()
    @Published var passwordFieldText: String = String()
    @Published var reInputPasswordFieldText: String = String()
    @Published var remainingTime: Int?
    
    var isProceedButtonDisabled: Bool {
        if authorizationCodeValidationState == .valid {
            // 비밀번호 설정 단계
            // 비밀번호 유효성 검증에 통과하고 재입력 비밀번호까지 같아야 통과인데 그렇지 않은 경우 버튼 비활성화
            return (passwordValidationState == .valid && passwordComparisonResult == .same) == false
        } else {
            // 인증코드 유효성 검증 단계
            // 인증 시간 만료되거나 인증코드 유효성 검증에 실패한 경우 버튼 비활성화
            return authorizationCodeValidationState == .timeout || authorizationCodeValidationState == .invalid
        }
    }
    
    @Published var emailValidationState: EmailValidationState = .beforeValidate
    @Published var authorizationCodeValidationState: AuthorizationCodeValidationState = .beforeValidate
    @Published var passwordValidationState: PasswordValidationState = .beforeValidate
    @Published var passwordComparisonResult: PasswordComparisonResult = .unknown
    
    private var timer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    private func subscribe() {
        $emailFieldText
            .removeDuplicates()
            .sink { [weak self] email in
                guard email.isEmpty == false else {
                    self?.emailValidationState = .beforeValidate
                    return
                }
                
                guard self?.isEmailValid(email) ?? false else {
                    self?.emailValidationState = .invalid
                    return
                }
                
                self?.emailValidationState = .beforeValidate
            }
            .store(in: &cancellables)
        
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
    
    func startTimer(seconds: Int) {
        emailValidationState = .valid
        authorizationCodeValidationState = .beforeValidate
        remainingTime = seconds
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    private func updateTimer() {
        guard let time = remainingTime, time > 1 else {
            timer?.cancel()
            timer = nil
            if authorizationCodeValidationState != .valid {
                authorizationCodeValidationState = .timeout
            }
            remainingTime = .zero
            return
        }
        
        remainingTime = time - 1
    }
    
    private func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
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

// MARK: Interfaces
extension AthentificationViewModel {
    
}
