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
    var authentificationState: AnyPublisher<AuthentificationCore.AuthentificationState, AuthentificationCoreError> { get }
    
    /// 사용자 정보
    var currentUser: AnyPublisher<User?, AuthentificationCoreError> { get }
    
    /// 로그인 필요 여부
    var isLoginNeeded: Bool { get }
    
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
    func checkEmailDuplicate(email: String) -> AnyPublisher<Bool, AuthentificationCoreError>
    
    /// 인증 코드 요청
    func requestAuthorizationCode(email: String) -> AnyPublisher<Void, AuthentificationCoreError>
    
    /// 인증 코드 검증
    func verifyAuthorizationCode(email: String, code: String) -> AnyPublisher<Bool, AuthentificationCoreError>
    
    /// 회원가입
    func register(email: String, password: String, nickname: String, profileImageData: Data?) -> AnyPublisher<Bool, AuthentificationCoreError>
    
    /// 회원탈퇴
    func unregister()
    
    /// 프로필 생성
    func createUserProfile(profileImageData: Data) -> AnyPublisher<User, AuthentificationCoreError>
    
    /// 프로필 수정
    func updateUserProfile(profileImageData: Data) -> AnyPublisher<User, AuthentificationCoreError>
    
    /// 프로필 삭제
    func deleteUserProfile() -> AnyPublisher<Bool, AuthentificationCoreError>
    
    /// 닉네임 변경
    func updateNickname(_ nickname: String) -> AnyPublisher<Bool, AuthentificationCoreError>
}

protocol AuthentificationMediationProtocol {
    /// 최근 사용자 정보 로드를 지시, 중재자에 의해 호출됨
    func loadCurrentUser()
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
    
    private var _currentUser: User?
    private var _pendingSocialUser: User?
    
    private let authentificationStateSubject = CurrentValueSubject<AuthentificationState, AuthentificationCoreError>(.loginNeeded)
    
    private let apiService: APIServable
    private let encoder: JSONEncoder
    private let strategyContext = AuthentificationStrategyContext()
    private var cancellables = Set<AnyCancellable>()
    
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
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure:
                    self?.resetAuthentifcationState()
                    self?.mediator?.notify(event: .userDidLogout)
                }
            } receiveValue: { [weak self] state in
                switch state {
                case .loginCompleted(let user):
                    self?._pendingSocialUser = nil
                    self?._currentUser = user
                    UserDefaults.standard.setValue(String(user.id), forKey: AppStorageKey.currentUserID)
                    self?.mediator?.notify(event: .userDidLogin(user: user))
                    
                case .registrationNeeded(let user):
                    self?._pendingSocialUser = user
                    self?._currentUser = nil
                    UserDefaults.standard.removeObject(forKey: AppStorageKey.currentUserID)
                    
                case .loginNeeded:
                    self?.resetAuthentifcationState()
                    self?.mediator?.notify(event: .userDidLogout)
                }
            }
            .store(in: &cancellables)
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
        apiService
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
            .store(in: &cancellables)
    }
    
    func resetAuthentifcationState() {
        _currentUser = nil
        _pendingSocialUser = nil
        UserDefaults.standard.removeObject(forKey: AppStorageKey.currentUserID)
    }
}

// MARK: AuthentificationCoreProtocol Conformation
extension AuthentificationCore: AuthentificationCoreProtocol {
    var authentificationState: AnyPublisher<AuthentificationState, AuthentificationCoreError> {
        authentificationStateSubject.eraseToAnyPublisher()
    }
    
    var currentUser: AnyPublisher<User?, AuthentificationCoreError> {
        authentificationStateSubject
            .map {
                guard case .loginCompleted(let user) = $0 else { return nil }
                return user
            }
            .eraseToAnyPublisher()
    }
    
    var isLoginNeeded: Bool { _currentUser == nil }
    
    func handleOpenURL(_ provider: AuthentificationProvider, _ url: URL) {
        strategyContext.handleOpenURL(url)
    }
    
    func loginWithApple(auth: ASAuthorization) {
        strategyContext.login(by: .apple(auth: auth)) { result in
            // TODO: WIP
        }
    }
    
    func loginWithKakao() {
        strategyContext.login(by: .kakao) { [weak self] result in
            guard let self else { return }
            
            guard case .success(let credential) = result,
                  let accessToken = credential.accessToken,
                  let refreshToken = credential.refreshToken
            else {
                authentificationStateSubject.send(completion: .failure(.socialAuthProviderAuthorizationFailed))
                return
            }
            
            apiService.requestPublisher(Endpoint.loginWithKakao(accessToken: accessToken, refreshToken: refreshToken), LoginWithKakaoDTO.Response.self)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        self?.authentificationStateSubject.send(completion: .failure(.networkRequestFailed(error)))
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
                .store(in: &cancellables)
        }
    }
    
    func loginWithNaver() {
        strategyContext.login(by: .naver) { result in
            // TODO: WIP
        }
    }
    
    func login(email: String, password: String) {
        // TODO: 이어서 구현하기
//        let dto = LoginDTO.Request(email: email, password: password)
//        
//        apiService
//            .requestPublisher(Endpoint.login(dto: dto), LoginDTO.Response.self)
    }
    
    func logout() {
        // TODO: 서버로 로그아웃 요청
    }
    
    func checkEmailDuplicate(email: String) -> AnyPublisher<Bool, AuthentificationCoreError> {
        let dto = CheckEmailDuplicationDTO.Request(email: email)
        
        return apiService
            .requestPublisher(Endpoint.checkEmailDuplication(dto: dto), Bool.self)
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .eraseToAnyPublisher()
    }
    
    func requestAuthorizationCode(email: String) -> AnyPublisher<Void, AuthentificationCoreError> {
        // TODO: 인증 코드 발급 요청 API 연결 필요
        Just(()).setFailureType(to: AuthentificationCoreError.self).eraseToAnyPublisher()
    }
    
    func verifyAuthorizationCode(email: String, code: String) -> AnyPublisher<Bool, AuthentificationCoreError> {
        // TODO: 인증 코드 확인 요청 API 연결 필요
        Just(true).setFailureType(to: AuthentificationCoreError.self).eraseToAnyPublisher()
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
            authentificationStateSubject.send(completion: .failure(.encodingFailed))
        }
    }
    
    func unregister() {
        // TODO: 기능 구현
    }
    
    func createUserProfile(profileImageData: Data) -> AnyPublisher<User, AuthentificationCoreError> {
        guard case .registrationNeeded(let user) = authentificationStateSubject.value else {
            return Fail(error: .notSupported).eraseToAnyPublisher()
        }
        
        return apiService.requestPublisher(Endpoint.uploadProfile(userID: user.id, image: profileImageData), UpdateProfileDTO.Response.self)
            .map {
                User(id: user.id, nickname: user.nickname, smsVerificationToken: user.smsVerificationToken, createdAt: user.createdAt, imageURL: $0.profileImageURL)
            }
            .handleEvents(receiveOutput: { [weak self] user in
                self?.readUserInfo(userID: user.id)
            })
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .eraseToAnyPublisher()
    }
    
    func updateUserProfile(profileImageData: Data) -> AnyPublisher<User, AuthentificationCoreError> {
        guard case .loginCompleted(let user) = authentificationStateSubject.value,
              user.imageURL != nil
        else {
            return Fail(error: .notSupported).eraseToAnyPublisher()
        }
        
        return apiService.requestPublisher(Endpoint.updateProfile(userID: user.id, image: profileImageData), UpdateProfileDTO.Response.self)
            .map {
                User(id: user.id, nickname: user.nickname, smsVerificationToken: user.smsVerificationToken, createdAt: user.createdAt, imageURL: $0.profileImageURL)
            }
            .handleEvents(receiveOutput: { [weak self] user in
                self?.readUserInfo(userID: user.id)
            })
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .eraseToAnyPublisher()
    }
    
    func deleteUserProfile() -> AnyPublisher<Bool, AuthentificationCoreError> {
        guard case .loginCompleted(let user) = authentificationStateSubject.value,
              user.imageURL != nil
        else {
            
        }
    }
    
    func updateNickname(_ nickname: String) -> AnyPublisher<Bool, AuthentificationCoreError> {
        
    }
}

// MARK: - AuthentificationMediationProtocol Conformation
extension AuthentificationCore: AuthentificationMediationProtocol {
    func loadCurrentUser() {
        guard let userIDString = UserDefaults.standard.string(forKey: AppStorageKey.currentUserID),
              let userID = UInt64(userIDString)
        else {
            authentificationStateSubject.send(completion: .failure(.autoLoginFailed))
            return
        }
        
        readUserInfo(userID: userID)
    }
}
