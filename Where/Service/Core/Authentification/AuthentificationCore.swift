//
//  AuthentificationCore.swift
//  Where
//
//  Created by Swain Yun on 2/28/25.
//

import Foundation
import AuthenticationServices
import Combine
import Moya

protocol AuthentificationCoreProtocol: CoreProtocol {
    /// 인증 상태
    var authentificationState: AnyPublisher<AuthentificationCore.AuthentificationState, Never> { get }
    
    /// 사용자 정보
    var currentUser: AnyPublisher<User?, Never> { get }
    
    /// Redirection URL Handling
    func handleOpenURL(_ provider: AuthentificationProvider, _ url: URL)
    
    /// 애플 로그인
    func loginWithApple(auth: ASAuthorization)
    
    /// 카카오 로그인
    func loginWithKakao()
    
    /// 네이버 로그인
    func loginWithNaver()
    
    /// 자체 로그인
    func login(email: String, password: String)
    
    /// 로그아웃
    func logout()
    
    /// 이메일 중복 확인
    func checkEmailDuplicate(email: String) -> AnyPublisher<Void, AuthentificationCoreError>
    
    /// 인증 코드 요청
    func requestAuthorizationCode(email: String) -> AnyPublisher<Void, AuthentificationCoreError>
    
    /// 인증 코드 검증
    func verifyAuthorizationCode(email: String, code: String) -> AnyPublisher<AuthorizationCodeValidationResult, AuthentificationCoreError>
    
    /// 회원가입
    func register(email: String, password: String, nickname: String, profileImageData: Data?) -> AnyPublisher<Bool, AuthentificationCoreError>
    
    /// 회원탈퇴
    func unregister() -> AnyPublisher<Void, AuthentificationCoreError>
    
    /// 프로필 생성
    func createUserProfile(profileImageData: Data) -> AnyPublisher<Void, AuthentificationCoreError>
    
    /// 프로필 수정
    func updateUserProfile(profileImageData: Data) -> AnyPublisher<Void, AuthentificationCoreError>
    
    /// 프로필 삭제
    func deleteUserProfile() -> AnyPublisher<Void, AuthentificationCoreError>
    
    /// 닉네임 변경
    func updateNickname(_ nickname: String) -> AnyPublisher<Void, AuthentificationCoreError>
}

protocol AuthentificationMediationProtocol {
    /// 최근 사용자 정보 로드를 지시, 중재자에 의해 호출됨
    func loadCurrentUser()
    /// 앱에서 받은 FCM Token 저장을 지시, 중재자에 의해 호출됨
    func fcmTokenUpdated(_ token: String)
}

enum AuthentificationCoreError: Error {
    /// 소셜로그인 공급자의 인가 과정 실패
    case socialAuthProviderAuthorizationFailed
    
    /// 로그인 실패
    case loginFailed
    
    /// 로그아웃 실패
    case logoutFailed
    
    /// 사용자 정보 가져오기 실패
    case userInfoFetchFailed
    
    /// 지원되지 않는 요청
    case notSupported
    
    /// 알 수 없는 에러
    case unknown(Error?)
    
    /// 네트워크 요청 실패
    case networkRequestFailed(Error)
    
    /// 토큰 만료 등으로 인한 자동 로그인 실패
    case autoLoginFailed
    
    /// 인코딩 실패
    case encodingFailed
}

private extension AuthentificationCore {
    enum Constants: String {
        case currentUserIdUserDefaultsKey = "currentUserId"
    }
}

final class AuthentificationCore {
    weak var mediator: Notifiable?
    
    private var fcmToken: String?
    
    private let authentificationStateSubject = CurrentValueSubject<AuthentificationState, Never>(.loginNeeded)
    
    private let apiService: APIServable
    private let encoder: JSONEncoder
    private let strategyContext = AuthentificationStrategyContext()
    private let cancellableBag = CancellableBag()
    
    init(
        apiService: APIServable,
        encoder: JSONEncoder
    ) {
        self.apiService = apiService
        self.encoder = encoder
        subscribe()
    }
    
    private func subscribe() {
        authentificationStateSubject
            .sink { [weak self] state in
                switch state {
                case .loginCompleted(let user):
                    UserDefaults.standard.setValue(String(user.id), forKey: AppStorageKey.currentUserID)
                    self?.mediator?.notify(event: .userDidLogin(user: user))
                    
                case .registrationNeeded:
                    self?.resetAuthentifcationState()
                    
                case .loginNeeded:
                    self?.resetAuthentifcationState()
                    self?.mediator?.notify(event: .userDidLogout)
                }
            }
            .store(in: cancellableBag, key: "AuthentificationStateSubject")
    }
}

// MARK: - Nested Types
extension AuthentificationCore {
    /// 인증 상태의 종류
    enum AuthentificationState {
        /// 필수 정보(닉네임)까지 설정된 회원정보 로드 성공
        case loginCompleted(User)
        /// 필수 정보(닉네임) 설정 필요
        case registrationNeeded(User)
        /// 로그인 필요
        case loginNeeded
    }
}

// MARK: - Private Methods
private extension AuthentificationCore {
    /// 사용자 회원정보 확인
    ///
    /// 소셜 로그인 후 필수정보(닉네임) 업데이트 성공 시 호출하여 최종 회원정보를 가져와 로그인 상태로 만듭니다.
    func readUserInfo(userID: UInt64) {
        cancellableBag[#function] = apiService
            .requestPublisher(Endpoint.readUserInfo(userID: userID), ReadUserInfoDTO.Response.self)
            .map { $0.toEntity() }
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure:
                    self?.authentificationStateSubject.send(.loginNeeded)
                }
            } receiveValue: { [weak self] user in
                guard user.nickname != nil else {
                    self?.authentificationStateSubject.send(.registrationNeeded(user))
                    return
                }
                
                self?.authentificationStateSubject.send(.loginCompleted(user))
            }
    }
    
    func resetAuthentifcationState() {
        UserDefaults.standard.removeObject(forKey: AppStorageKey.currentUserID)
    }
}

// MARK: AuthentificationCoreProtocol Conformation
extension AuthentificationCore: AuthentificationCoreProtocol {
    var authentificationState: AnyPublisher<AuthentificationState, Never> {
        authentificationStateSubject.eraseToAnyPublisher()
    }
    
    var currentUser: AnyPublisher<User?, Never> {
        authentificationStateSubject
            .map {
                guard case .loginCompleted(let user) = $0 else { return nil }
                return user
            }
            .eraseToAnyPublisher()
    }
    
    func handleOpenURL(_ provider: AuthentificationProvider, _ url: URL) {
        strategyContext.handleOpenURL(url)
    }
    
    func loginWithApple(auth: ASAuthorization) {
        strategyContext.login(by: .apple(auth: auth)) { result in
            // TODO: WIP
        }
    }
    
    func loginWithKakao() {
        cancellableBag[#function] = Future<UserCredential, AuthentificationCoreError> { [weak self] promise in
            self?.strategyContext.login(by: .kakao) { result in
                switch result {
                case .failure(let error): promise(.failure(error))
                case .success(let credential): promise(.success(credential))
                }
            }
        }
        .flatMap { [weak self] credential -> AnyPublisher<LoginWithKakaoDTO.Response, AuthentificationCoreError> in
            guard let self,
                  let accessToekn = credential.accessToken,
                  let refreshToken = credential.refreshToken
            else {
                return Fail(error: .socialAuthProviderAuthorizationFailed).eraseToAnyPublisher()
            }
            
            return apiService.requestPublisher(Endpoint.loginWithKakao(accessToken: accessToekn, refreshToken: refreshToken), LoginWithKakaoDTO.Response.self)
                .mapError { AuthentificationCoreError.networkRequestFailed($0) }
                .eraseToAnyPublisher()
        }
        .sink { [weak self] completion in
            switch completion {
            case .finished: break
            case .failure:
                self?.authentificationStateSubject.send(.loginNeeded)
            }
        } receiveValue: { [weak self] response in
            if response.isRegistrationNeeded {
                // 프로필 설정 필요
                let user = User(id: response.userID, imageURL: response.profileImageURL)
                self?.authentificationStateSubject.send(.registrationNeeded(user))
            } else {
                // 프로필 설정 불필요
                self?.readUserInfo(userID: response.userID)
            }
        }
    }
    
    func loginWithNaver() {
        strategyContext.login(by: .naver) { result in
            // TODO: WIP
        }
    }
    
    func login(email: String, password: String) {
        let dto = LoginDTO.Request(email: email, password: password)
        
        cancellableBag[#function] = apiService.requestPublisher(Endpoint.login(dto: dto), EmptyDTO.Response.self)
            .sink { [weak self] completion in
                guard case .failure = completion else { return }
                self?.authentificationStateSubject.send(.loginNeeded)
            } receiveValue: { [weak self] _ in
                // TODO: 발급된 토큰 저장할 수 있는지 확인
                // TODO: API 응답 스펙 맞춰서 로직 구현해야함
            }
    }
    
    func logout() {
        // TODO: 서버로 로그아웃 요청
    }
    
    func checkEmailDuplicate(email: String) -> AnyPublisher<Void, AuthentificationCoreError> {
        let dto = CheckEmailDuplicationDTO.Request(email: email)
        
        return apiService.requestPublisher(Endpoint.checkEmailDuplication(dto: dto))
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func requestAuthorizationCode(email: String) -> AnyPublisher<Void, AuthentificationCoreError> {
        apiService.requestPublisher(Endpoint.requestAuthCode(email: email))
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func verifyAuthorizationCode(email: String, code: String) -> AnyPublisher<AuthorizationCodeValidationResult, AuthentificationCoreError> {
        let dto = VerifyAuthCodeDTO.Request(email: email, code: code)
        return apiService.requestPublisher(Endpoint.verifyAuthCode(dto: dto))
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .map { AuthorizationCodeValidationResult($0) }
            .eraseToAnyPublisher()
    }
    
    func register(email: String, password: String, nickname: String, profileImageData: Data?) -> AnyPublisher<Bool, AuthentificationCoreError> {
        do {
            let dto = RegisterDTO.Request(email: email, password: password, nickname: nickname)
            let encodedUserData = try encoder.encode(dto)
            
            return apiService.requestPublisher(Endpoint.register(encodedUserData: encodedUserData, profileImageData: profileImageData), RegisterDTO.Response.self)
                .map { _ in
                    // TODO: 응답 스펙 확인 필요
                    false
                }
                .mapError { AuthentificationCoreError.networkRequestFailed($0) }
                .eraseToAnyPublisher()
            
        } catch {
            print("Failed Encoding")
            return Fail(error: .networkRequestFailed(error)).eraseToAnyPublisher()
        }
    }
    
    func unregister() -> AnyPublisher<Void, AuthentificationCoreError> {
        guard case .loginCompleted(let user) = authentificationStateSubject.value else {
            return Fail(error: .userInfoFetchFailed).eraseToAnyPublisher()
        }
        
        return apiService
            .requestPublisher(Endpoint.unregister(userID: user.id), EmptyDTO.Response.self)
            .map { [weak self] _ in
                self?.authentificationStateSubject.send(.loginNeeded)
            }
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .eraseToAnyPublisher()
    }
    
    func createUserProfile(profileImageData: Data) -> AnyPublisher<Void, AuthentificationCoreError> {
        guard case .registrationNeeded(let user) = authentificationStateSubject.value else {
            return Fail(error: .notSupported).eraseToAnyPublisher()
        }
        
        return apiService.requestPublisher(Endpoint.uploadProfile(userID: user.id, image: profileImageData), UpdateProfileDTO.Response.self)
            .handleEvents(receiveOutput: { [weak self] response in
                let user = User(
                    id: user.id,
                    nickname: user.nickname,
                    smsVerificationToken: user.smsVerificationToken,
                    createdAt: user.createdAt,
                    imageURL: response.profileImageURL
                )
                self?.readUserInfo(userID: user.id)
            })
            .map { _ in }
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .eraseToAnyPublisher()
    }
    
    func updateUserProfile(profileImageData: Data) -> AnyPublisher<Void, AuthentificationCoreError> {
        switch authentificationStateSubject.value {
        case .loginCompleted(let user), .registrationNeeded(let user):
            return apiService.requestPublisher(Endpoint.updateProfile(userID: user.id, image: profileImageData), UpdateProfileDTO.Response.self)
                .handleEvents(receiveOutput: { [weak self] response in
                    let user = User(
                        id: user.id,
                        nickname: user.nickname,
                        smsVerificationToken: user.smsVerificationToken,
                        createdAt: user.createdAt,
                        imageURL: response.profileImageURL
                    )
                    self?.readUserInfo(userID: user.id)
                })
                .map { _ in }
                .mapError { AuthentificationCoreError.networkRequestFailed($0) }
                .eraseToAnyPublisher()
            
        case .loginNeeded:
            return Fail(error: .notSupported).eraseToAnyPublisher()
        }
    }
    
    func deleteUserProfile() -> AnyPublisher<Void, AuthentificationCoreError> {
        switch authentificationStateSubject.value {
        case .loginCompleted(let user), .registrationNeeded(let user):
            return apiService.requestPublisher(Endpoint.deleteProfile(userID: user.id), EmptyDTO.Response.self)
                .map { _ in () }
                .mapError { AuthentificationCoreError.networkRequestFailed($0) }
                .eraseToAnyPublisher()
            
        case .loginNeeded:
            return Fail(error: .notSupported).eraseToAnyPublisher()
        }
    }
    
    func updateNickname(_ nickname: String) -> AnyPublisher<Void, AuthentificationCoreError> {
        let dto = UpdateNicknameDTO.Request(nickname: nickname)
        
        switch authentificationStateSubject.value {
        case .loginCompleted(let user), .registrationNeeded(let user):
            return apiService.requestPublisher(Endpoint.updateNickname(userID: user.id, dto: dto), EmptyDTO.Response.self)
                .map { _ in () }
                .mapError { AuthentificationCoreError.networkRequestFailed($0) }
                .eraseToAnyPublisher()
            
        case .loginNeeded:
            return Fail(error: .notSupported).eraseToAnyPublisher()
        }
    }
}

// MARK: - AuthentificationMediationProtocol Conformation
extension AuthentificationCore: AuthentificationMediationProtocol {
    func loadCurrentUser() {
        guard let userIDString = UserDefaults.standard.string(forKey: AppStorageKey.currentUserID),
              let userID = UInt64(userIDString)
        else { return }
        
        readUserInfo(userID: userID)
    }
    
    func fcmTokenUpdated(_ token: String) {
        fcmToken = token
    }
}
