//
//  AuthentificationViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/21/25.
//

import SwiftUI
import Combine

@MainActor
final class RegistrationViewModel: ObservableObject {
    @Published var emailFieldText: String = String()
    @Published var authorizationCodeFieldText: String = String()
    @Published var passwordFieldText: String = String()
    @Published var reInputPasswordFieldText: String = String()
    @Published var nicknameFieldText: String = String()
    @Published var remainingTime: Int?
    @Published var profileImage: UIImage? = UIImage(named: "person")
    @Published var isPopupPresented: Bool = false
    @Published var floater: FloaterType?
    @Published var isCompleted: Bool = false
    
    var emailValidationState: EmailValidationState = .beforeValidate
    var authorizationCodeValidationState: AuthorizationCodeValidationState = .beforeValidate
    var passwordValidationState: PasswordValidationState = .beforeValidate
    var passwordComparisonResult: PasswordComparisonResult = .unknown
    var nicknameValidationState: NicknameValidationState = .beforeValidate
    var registrationStep: RegistrationTerminationStep = .email
    
    private let auth: any AuthentificationCoreProtocol
    
    var navigationTitle: String {
        switch registrationStep {
        case .email:
            "가입을 위한 이메일을\n인증해주세요"
        case .password:
            "설정할 비밀번호를\n입력해주세요"
        case .profile:
            "프로필을 설정해주세요"
        case .completed:
            "\(nicknameFieldText)님,\n회원가입을 축하합니다!"
        }
    }
    
    var isProceedButtonDisabled: Bool {
        switch registrationStep {
        case .email: return emailValidationState != .valid || authorizationCodeValidationState != .valid
        case .password: return passwordValidationState != .valid || passwordComparisonResult != .same
        case .profile: return nicknameValidationState != .valid
        case .completed: return true
        }
    }
    
    private var timer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init(auth: any AuthentificationCoreProtocol) {
        self.auth = auth
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
    func requestAuthorizationCode() {
        // TODO: 인증코드 요청
        floater = .authorizationCodeSended
    }
    
    func proceedButtonLabel() -> String {
        registrationStep == .completed ? "완료" : "다음"
    }
    
    func proceed() {
        guard isProceedButtonDisabled == false else { return }
        
        switch registrationStep {
        case .email: registrationStep = .password
        case .password: registrationStep = .profile
        case .profile: registrationStep = .completed
        case .completed: isCompleted = true
        }
    }
    
    func nicknameValidationNotice() -> String {
        switch nicknameValidationState {
        case .valid: "사용 가능한 닉네임입니다."
        case .invalid, .beforeValidate: "2~8자의 영문, 숫자, 한글, 특수문자(-, _)만 사용할 수 있습니다."
        case .duplicated: "이미 사용 중인 닉네임입니다."
        }
    }
    
    func nicknameValidationNoticeColor() -> Color {
        switch nicknameValidationState {
        case .valid: .green
        case .beforeValidate: .where(.gray700)
        case .invalid, .duplicated: .red
        }
    }
    
    func flush() {
        emailFieldText.removeAll()
        authorizationCodeFieldText.removeAll()
        passwordFieldText.removeAll()
        reInputPasswordFieldText.removeAll()
        nicknameFieldText.removeAll()
        remainingTime = nil
        profileImage = UIImage(named: "person")
        isPopupPresented = false
        floater = nil
        isCompleted = false
        emailValidationState = .beforeValidate
        authorizationCodeValidationState = .beforeValidate
        passwordValidationState = .beforeValidate
        passwordComparisonResult = .unknown
        nicknameValidationState = .beforeValidate
        registrationStep = .email
    }
}
