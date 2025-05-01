//
//  RegistrationViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/21/25.
//

import Foundation
import Combine
import Swinject

@MainActor
final class RegistrationViewModel: ObservableObject {
    @Published var emailFieldText: String = String()
    @Published var authorizationCodeFieldText: String = String()
    @Published var passwordFieldText: String = String()
    @Published var reInputPasswordFieldText: String = String()
    @Published var remainingTime: Int?
    @Published var floater: FloaterType?
    @Published var isCompleted: Bool = false
    
    private(set) var emailValidationState: EmailValidationState = .beforeValidate
    private(set) var authorizationCodeValidationState: AuthorizationCodeValidationState = .beforeValidate
    private(set) var passwordValidationState: PasswordValidationState = .beforeValidate
    private(set) var passwordComparisonResult: PasswordComparisonResult = .unknown
    private(set) var registrationStep: RegistrationTerminationStep = .email
    
    private let authCore: AuthentificationCoreProtocol
    
    var navigationTitle: String {
        switch registrationStep {
        case .email:
            "가입을 위한 이메일을\n인증해주세요"
        case .password:
            "설정할 비밀번호를\n입력해주세요"
        }
    }
    
    var isProceedButtonDisabled: Bool {
        switch registrationStep {
        case .email: return emailValidationState != .validOnServer || authorizationCodeValidationState != .valid
        case .password: return passwordValidationState != .valid || passwordComparisonResult != .same
        }
    }
    
    private var timer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
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
    
    private func startTimer(seconds: Int) {
        emailValidationState = .validOnServer
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

// MARK: Nested Types
extension RegistrationViewModel {
    enum FloaterType: FloaterContent {
        case authorizationCodeSended
        case inValidAuthorizationCode
        
        var title: String {
            switch self {
            case .authorizationCodeSended: "인증코드가 전송되었습니다."
            case .inValidAuthorizationCode: "인증코드가 잘못되었습니다."
            }
        }
    }
}

// MARK: Interfaces
extension RegistrationViewModel {
    func checkEmailDuplicate() {
        authCore.checkEmailDuplicate(email: emailFieldText)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { isDuplecated in
                guard isDuplecated else {
                    
                    return
                }
                
            }
            .store(in: &cancellables)
    }
    
    func requestAuthorizationCode() {
        authCore.requestAuthorizationCode(email: emailFieldText)
        floater = .authorizationCodeSended
        startTimer(seconds: 20)
    }
    
    func proceed() {
        guard isProceedButtonDisabled == false else { return }
        
        switch registrationStep {
        case .email: registrationStep = .password
        case .password: isCompleted = true
        }
    }
}
