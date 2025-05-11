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
    private struct SubscriptionKey {
        static let timer = "Timer"
        static let emailValidation = "EmailValidation"
        static let authCodeRequest = "AuthCodeRequest"
        static let authCodeValidation = "AuthCodeValidation"
        static let nicknameValidation = "NicknameValidation"
        static let registration = "Registration"
    }
    
    @Published var emailFieldText: String = String()
    @Published var authorizationCodeFieldText: String = String()
    @Published var passwordFieldText: String = String()
    @Published var reInputPasswordFieldText: String = String()
    @Published var nicknameFieldText: String = String()
    @Published var remainingTime: Int?
    @Published var profileImageData: Data?
    @Published var isPopupPresented: Bool = false
    @Published var floater: FloaterType?
    @Published var isCompleted: Bool = false
    
    @Published private(set) var emailValidationState: EmailValidationState = .beforeValidate
    @Published private(set) var passwordValidationState: PasswordValidationState = .beforeValidate
    @Published private(set) var passwordComparisonResult: PasswordComparisonResult = .unknown
    @Published private(set) var nicknameValidationState: NicknameValidationState = .beforeValidate
    @Published private(set) var registrationStep: RegistrationTerminationStep = .email
    
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
        case .email:
            if emailValidationState == .requested { return authorizationCodeFieldText.isEmpty }
            return emailValidationState != .valid
        case .password:
            return passwordComparisonResult != .same
        case .profile:
            return nicknameValidationState != .valid
        case .completed:
            return false
        }
    }
    
    var proceedButtonLabel: String {
        registrationStep == .completed ? "완료" : "다음"
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
        switch emailValidationState {
        case .timeout: "인증 시간이 만료되었습니다."
        default: String()
        }
    }
    
    var requestAuthorizationCodeDisabled: Bool {
        guard emailFieldText.isEmpty == false else { return true }
        return emailValidationState != .awaitingCode
    }
    
    var nicknameValidationNotice: String {
        switch nicknameValidationState {
        case .valid: "사용 가능한 닉네임입니다."
        case .invalid, .beforeValidate: "2~8자의 영문, 숫자, 한글, 특수문자(-, _)만 사용할 수 있습니다."
        case .duplicated: "이미 사용 중인 닉네임입니다."
        }
    }
    
    private let authCore: AuthentificationCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        $emailFieldText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                // 이메일 변경 시 이전 API 작업 취소
                self?.cancellableBag.cancel(SubscriptionKey.emailValidation)
                self?.cancellableBag.cancel(SubscriptionKey.authCodeRequest)
                self?.cancellableBag.cancel(SubscriptionKey.authCodeValidation)
                
                self?.stopTimer()
                self?.authorizationCodeFieldText = String()
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
            .store(in: cancellableBag, key: "EmailFieldText")
        
        $passwordFieldText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self else { return }
                
                guard password.isEmpty == false else {
                    passwordValidationState = .beforeValidate
                    checkPasswordComparison()
                    return
                }
                
                if isPasswordValid(password) {
                    passwordValidationState = .valid
                } else {
                    passwordValidationState = .invalid
                }
            }
            .store(in: cancellableBag, key: "PasswordFieldText")
        
        $reInputPasswordFieldText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkPasswordComparison()
            }
            .store(in: cancellableBag, key: "ReInputPasswordFieldText")
        
        $nicknameFieldText
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] nickname in
                guard nickname.isEmpty == false else {
                    self?.nicknameValidationState = .beforeValidate
                    return
                }
                
                guard nickname.isValidNickname() else {
                    self?.nicknameValidationState = .invalid
                    return
                }
                
                self?.nicknameValidationState = .valid
            }
            .store(in: cancellableBag, key: "NicknameFieldText")
    }
    
    private func startTimer(seconds: Int) {
        stopTimer()
        remainingTime = seconds
        
        cancellableBag[SubscriptionKey.timer] = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    private func updateTimer() {
        guard let time = remainingTime, time > 1 else {
            stopTimer()
            if emailValidationState != .valid {
                emailValidationState = .timeout
            }
            remainingTime = .zero
            return
        }
        
        remainingTime = time - 1
    }
    
    private func stopTimer() {
        cancellableBag[SubscriptionKey.timer]?.cancel()
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
    
    private func checkEmailDuplicate(_ email: String) {
        emailValidationState = .checkingDuplication
        
        cancellableBag[SubscriptionKey.emailValidation] = authCore.checkEmailDuplicate(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure:
                    self?.emailValidationState = .emailDuplicated
                }
            } receiveValue: { [weak self] _ in
                self?.emailValidationState = .awaitingCode
            }
    }
    
    private func verifyAuthorizationCode(_ email: String, code: String) {
        emailValidationState = .checkingAuthorizationCode
        
        cancellableBag[SubscriptionKey.authCodeValidation] = authCore.verifyAuthorizationCode(email: email, code: code)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure:
                    self?.floater = .errorOccured(message: "인증코드 확인 작업이 중단되었어요.")
                    self?.emailValidationState = .invalid
                    self?.stopTimer()
                }
            } receiveValue: { [weak self] result in
                switch result {
                case .verified:
                    self?.emailValidationState = .valid
                    self?.stopTimer()
                    self?.registrationStep = .password
                    self?.passwordValidationState = .beforeValidate
                    self?.passwordComparisonResult = .unknown
                    self?.passwordFieldText = String()
                    self?.reInputPasswordFieldText = String()
                    
                case .notVerified:
                    self?.floater = .inValidAuthorizationCode
                    self?.emailValidationState = .invalid
                }
            }
    }
    
    private func checkPasswordComparison() {
        guard passwordFieldText.isEmpty == false,
              reInputPasswordFieldText.isEmpty == false
        else {
            passwordComparisonResult = .unknown
            return
        }
        
        passwordComparisonResult = (passwordFieldText == reInputPasswordFieldText) ? .same : .different
    }
    
    private func register() {
        cancellableBag[SubscriptionKey.registration] = authCore.register(email: emailFieldText, password: passwordFieldText, nickname: nicknameFieldText, profileImageData: profileImageData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure:
                    self?.floater = .errorOccured(message: "잠시 후 다시 시도해주세요.")
                }
            } receiveValue: { [weak self] isDone in
                self?.isCompleted = isDone
            }
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
    func requestAuthorizationCode() {
        guard emailValidationState == .awaitingCode else {
            floater = .errorOccured(message: "인증코드를 발급할 수 없어요.")
            return
        }
        
        emailValidationState = .requesting
        
        cancellableBag[SubscriptionKey.authCodeRequest] = authCore.requestAuthorizationCode(email: emailFieldText)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.floater = .authorizationCodeSended
                    self?.startTimer(seconds: 10 * 60)
                    self?.emailValidationState = .requested
                case .failure:
                    self?.floater = .errorOccured(message: "잠시 후 다시 시도해주세요.")
                    self?.emailValidationState = .awaitingCode
                }
            } receiveValue: { _ in }
    }
    
    func proceed() {
        guard isProceedButtonDisabled == false else { return }
        
        switch registrationStep {
        case .email:
            if emailValidationState == .valid {
                // 인증코드 유효성 검증이 끝난 상황이라면 다음 회원가입 단계로 진행
                registrationStep = .password
                passwordValidationState = .beforeValidate
                passwordComparisonResult = .unknown
                passwordFieldText.removeAll()
                reInputPasswordFieldText.removeAll()
            } else {
                // 인증코드 유효성 검증 전이라면 검증 API 호출
                guard authorizationCodeFieldText.isEmpty == false else { return }
                verifyAuthorizationCode(emailFieldText, code: authorizationCodeFieldText)
            }
            
        case .password:
            guard passwordValidationState == .valid, passwordComparisonResult == .same else { return }
            registrationStep = .profile
            nicknameFieldText.removeAll()
            profileImageData = nil
            
        case .profile:
            register()
            
        case .completed:
            isCompleted = true
        }
    }
    
    func onDisappear() {
        emailFieldText = String()
        authorizationCodeFieldText = String()
        passwordFieldText = String()
        reInputPasswordFieldText = String()
        nicknameFieldText = String()
        remainingTime = nil
        profileImageData = nil
        isPopupPresented = false
        floater = nil
        isCompleted = false
        
        emailValidationState = .beforeValidate
        passwordValidationState = .beforeValidate
        passwordComparisonResult = .unknown
        nicknameValidationState = .beforeValidate
        registrationStep = .email
    }
}
