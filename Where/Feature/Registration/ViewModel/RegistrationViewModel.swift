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
    
    @Published private(set) var emailValidationState: EmailValidationState = .beforeValidate
    @Published private(set) var authorizationCodeValidationState: AuthorizationCodeValidationState = .beforeValidate
    @Published private(set) var passwordValidationState: PasswordValidationState = .beforeValidate
    @Published private(set) var passwordComparisonResult: PasswordComparisonResult = .unknown
    @Published private(set) var registrationStep: RegistrationTerminationStep = .email
    
    private var registrationProcess: AnyPublisher<(email: String, password: String), Never> {
        registrationProcessSubject.eraseToAnyPublisher()
    }
    
    private let authCore: AuthentificationCoreProtocol
    private let registrationProcessSubject = PassthroughSubject<(email: String, password: String), Never>()
    
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
        case .email: return authorizationCodeValidationState != .valid
        case .password: return passwordValidationState != .valid || passwordComparisonResult != .same
        }
    }
    
    var emailValidationNotice: String {
        switch emailValidationState {
        case .invalidOnLocal: "잘못된 이메일 주소입니다."
        case .emailDuplicated: "이미 가입된 이메일입니다."
        default: String()
        }
    }
    
    var isEmailInvalid: Bool {
        emailValidationState == .invalidOnLocal || emailValidationState == .emailDuplicated
    }
    
    var authorizationCodeValidationNotice: String {
        switch authorizationCodeValidationState {
        case .timeout: "인증 시간이 만료되었습니다."
        default: String()
        }
    }
    
    var requestAuthorizationCodeDisabled: Bool {
        emailFieldText.isEmpty || emailValidationState == .invalidOnLocal ||
        authorizationCodeValidationState == .valid
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
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                self?.stopTimer()
                self?.authorizationCodeFieldText = String()
                self?.authorizationCodeValidationState = .beforeValidate
                self?.registrationStep = .email
                
                guard email.isEmpty == false else {
                    self?.emailValidationState = .beforeValidate
                    return
                }
                
                guard self?.isEmailValid(email) ?? false else {
                    self?.emailValidationState = .invalidOnLocal
                    return
                }
                
                self?.checkEmailDuplicate(email)
            }
            .store(in: &cancellables)
        
        $passwordFieldText
            .removeDuplicates()
            .sink { [weak self] password in
                guard let self else { return }
                
                guard password.isEmpty == false else {
                    passwordValidationState = .beforeValidate
                    passwordComparisonResult = .unknown
                    return
                }
                
                if isPasswordValid(password) {
                    passwordValidationState = .valid
                } else {
                    passwordValidationState = .invalid
                }
            }
            .store(in: &cancellables)
        
        $reInputPasswordFieldText
            .removeDuplicates()
            .sink { [weak self] password in
                guard let self else { return }
                
                if passwordValidationState == .valid, reInputPasswordFieldText.isEmpty == false {
                    passwordComparisonResult = passwordFieldText == reInputPasswordFieldText ? .same : .different
                } else if reInputPasswordFieldText.isEmpty {
                    passwordComparisonResult = .unknown
                } else {
                    passwordComparisonResult = .unknown
                }
            }
            .store(in: &cancellables)
    }
    
    private func startTimer(seconds: Int) {
        authorizationCodeValidationState = .beforeValidate
        remainingTime = seconds
        timer?.cancel()
        
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
            remainingTime = nil
            return
        }
        
        remainingTime = time - 1
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
        remainingTime = nil
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
    
    private func verifyAuthorizationCode(_ email: String, code: String) {
        authorizationCodeValidationState = .checkingAuthorizationCode
        
        authCore.verifyAuthorizationCode(email: email, code: code)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure:
                    self?.floater = .errorOccured(message: "인증코드 확인 작업이 중단되었어요.")
                    self?.authorizationCodeValidationState = .invalid
                }
            } receiveValue: { [weak self] isVerified in
                if isVerified {
                    self?.authorizationCodeValidationState = .valid
                    self?.stopTimer()
                    self?.registrationStep = .password
                    self?.passwordValidationState = .beforeValidate
                    self?.passwordComparisonResult = .unknown
                    self?.passwordFieldText = String()
                    self?.reInputPasswordFieldText = String()
                } else {
                    self?.floater = .inValidAuthorizationCode
                    self?.authorizationCodeValidationState = .invalid
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: Nested Types
extension RegistrationViewModel {
    enum FloaterType: FloaterContent {
        case authorizationCodeSended
        case inValidAuthorizationCode
        case errorOccured(message: String)
        
        var title: String {
            switch self {
            case .authorizationCodeSended: "인증코드가 전송되었습니다."
            case .inValidAuthorizationCode: "인증코드가 잘못되었습니다."
            case .errorOccured(let message): message
            }
        }
    }
    
    enum KeyboardFocusState: Hashable {
        case emailTextField, authorizationCodeTextField, passwordTextField, reInputPasswordTextField
    }
}

// MARK: Interfaces
extension RegistrationViewModel {
    func checkEmailDuplicate(_ email: String) {
        emailValidationState = .checkingDuplication
        
        authCore.checkEmailDuplicate(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure:
                    self?.floater = .errorOccured(message: "이메일 중복 확인이 이루어지지 않았어요.")
                    self?.emailValidationState = .beforeValidate
                }
            } receiveValue: { [weak self] isDuplecated in
                self?.emailValidationState = isDuplecated ? .emailDuplicated : .valid
            }
            .store(in: &cancellables)
    }
    
    func requestAuthorizationCode() {
        guard emailValidationState == .valid else { return }
        
        authCore.requestAuthorizationCode(email: emailFieldText)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.floater = .authorizationCodeSended
                    self?.startTimer(seconds: 3 * 60)
                    self?.authorizationCodeValidationState = .beforeValidate
                    self?.authorizationCodeFieldText = String()
                case .failure:
                    self?.floater = .errorOccured(message: "잠시 후 다시 시도해주세요.")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func proceed() {
        // TODO: '다음'버튼을 눌러 인증코드 검증 요청 보내는 로직 추가하기
        guard isProceedButtonDisabled == false else { return }
        
        switch registrationStep {
        case .email:
            guard authorizationCodeValidationState == .valid else { return }
            
            registrationStep = .password
            passwordValidationState = .beforeValidate
            passwordComparisonResult = .unknown
            passwordFieldText = String()
            reInputPasswordFieldText = String()
            
        case .password:
            guard passwordValidationState == .valid, passwordComparisonResult == .same else { return }
            registrationProcessSubject.send((emailFieldText, passwordFieldText))
        }
    }
    
    func textFieldLineColorHex(currentFocused: KeyboardFocusState?, focus: KeyboardFocusState) -> Int {
        var isInvalid: Bool
        
        switch focus {
        case .emailTextField:
            isInvalid = emailValidationState == .invalidOnLocal || emailValidationState == .emailDuplicated
        case .authorizationCodeTextField:
            isInvalid = authorizationCodeValidationState == .timeout
        case .passwordTextField:
            isInvalid = passwordValidationState == .invalid
        case .reInputPasswordTextField:
            isInvalid = passwordComparisonResult == .different
        }
        
        guard isInvalid == false else { return 0xEF4444 }
        return currentFocused == focus ? 0x4F46E5 : 0xE5E7EB
    }
}
