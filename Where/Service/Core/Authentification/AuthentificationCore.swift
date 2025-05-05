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
    /// 사용자 정보
    var currentUser: AnyPublisher<User?, AuthentificationCoreError> { get }
    
    /// 소셜로그인 회원가입 시 프로필 설정 필요 여부
    var isRegistrationNeeded: AnyPublisher<Bool, Never> { get }
    
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
    func requestAuthorizationCode(email: String)
    
    /// 회원가입
    func register(email: String, password: String, nickname: String, profileImageData: Data?)
    
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
}

private extension AuthentificationCore {
    enum Constants: String {
        case currentUserIdUserDefaultsKey = "currentUserId"
    }
}

final class AuthentificationCore {
    weak var mediator: Notifiable?
    
    private var _currentUser: User?
    private var _pendingSocialUserID: UInt64?
    
    private let currentUserSubject = CurrentValueSubject<User?, AuthentificationCoreError>(nil)
    private let isRegistrationNeededSubject = PassthroughSubject<Bool, Never>()
    
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
        currentUserSubject
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print("AuthentificationCore Error: \(error)")
                    #endif
                    
                    UserDefaults.standard.removeObject(forKey: AppStorageKey.currentUserID)
                    self?.mediator?.notify(event: .userDidLogout)
                }
            } receiveValue: { [weak self] user in
                if let user = user, user.nickname != nil {
                    // 닉네임까지 모두 설정된 회원정보가 발행된 경우
                    UserDefaults.standard.setValue(String(user.id), forKey: AppStorageKey.currentUserID)
                    self?._pendingSocialUserID = nil
                    self?.isRegistrationNeededSubject.send(false)
                    self?._currentUser = user
                    self?.mediator?.notify(event: .userDidLogin(user: user))
                } else {
                    // 회원정보가 nil 이거나(로그아웃), 닉네임이 설정되지 않은 임시적 소셜 회원정보가 발행된 경우
                    UserDefaults.standard.removeObject(forKey: AppStorageKey.currentUserID)
                    self?.mediator?.notify(event: .userDidLogout)
                }
            }
            .store(in: &cancellables)
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
                    self?._pendingSocialUserID = nil
                }
            } receiveValue: { [weak self] user in
                self?.currentUserSubject.send(user)
                self?._pendingSocialUserID = nil
                self?.isRegistrationNeededSubject.send(false)
            }
            .store(in: &cancellables)
    }
}

// MARK: AuthentificationCoreProtocol Conformation
extension AuthentificationCore: AuthentificationCoreProtocol {
    var currentUser: AnyPublisher<User?, AuthentificationCoreError> {
        currentUserSubject.eraseToAnyPublisher()
    }
    
    var isRegistrationNeeded: AnyPublisher<Bool, Never> {
        isRegistrationNeededSubject.eraseToAnyPublisher()
    }
    
    var isLoginNeeded: Bool {
        _currentUser == nil
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
        strategyContext.login(by: .kakao) { [weak self] result in
            guard let self else { return }
            
            guard case .success(let credential) = result,
                  let accessToken = credential.accessToken,
                  let refreshToken = credential.refreshToken
            else {
                currentUserSubject.send(completion: .failure(.socialAuthProviderAuthorizationFailed))
                _pendingSocialUserID = nil
                return
            }
            
            apiService.requestPublisher(Endpoint.loginWithKakao(accessToken: accessToken, refreshToken: refreshToken), LoginWithKakaoDTO.Response.self)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        self?.currentUserSubject.send(completion: .failure(.networkRequestFailed(error)))
                        self?.isRegistrationNeededSubject.send(false)
                        self?._pendingSocialUserID = nil
                    }
                } receiveValue: { [weak self] response in
                    self?.isRegistrationNeededSubject.send(response.isRegistrationNeeded)
                    
                    if response.isRegistrationNeeded {
                        // 프로필 설정 필요
                        self?._pendingSocialUserID = response.userID
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
        currentUserSubject.send(nil)
        mediator?.notify(event: .userDidLogout)
    }
    
    func checkEmailDuplicate(email: String) -> AnyPublisher<Bool, AuthentificationCoreError> {
        let dto = CheckEmailDuplicationDTO.Request(email: email)
        
        return apiService
            .requestPublisher(Endpoint.checkEmailDuplication(dto: dto), Bool.self)
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .eraseToAnyPublisher()
    }
    
    func requestAuthorizationCode(email: String) {
        // TODO: 인증 코드 발급 요청 API 연결 필요
    }
    
    func register(email: String, password: String, nickname: String, profileImageData: Data?) {
        do {
            let dto = RegisterDTO.Request(email: email, password: password, nickname: nickname)
            let encodedUserData = try encoder.encode(dto)
            apiService.requestPublisher(Endpoint.register(encodedUserData: encodedUserData, profileImageData: profileImageData), RegisterDTO.Response.self)
                .sink { completion in
                    // TODO: 에러 핸들링
                } receiveValue: { [weak self] _ in
                    // TODO: 구현 방향 결정되면 수정하기
                }
                .store(in: &cancellables)

        } catch {
            currentUserSubject.send(completion: .failure(.userInfoFetchFailed))
        }
    }
    
    func unregister() {
        // TODO: 기능 구현
    }
    
    func createUserProfile(profileImageData: Data) -> AnyPublisher<User, AuthentificationCoreError> {
        guard let user = currentUserSubject.value else {
            return Fail(error: AuthentificationCoreError.userInfoFetchFailed).eraseToAnyPublisher()
        }
        
        return apiService.requestPublisher(Endpoint.uploadProfile(userID: user.id, image: profileImageData), UpdateProfileDTO.Response.self)
            .map {
                return User(id: user.id, nickname: user.nickname, smsVerificationToken: user.smsVerificationToken, createdAt: user.createdAt, imageURL: $0.profileImageURL)
            }
            .handleEvents(receiveOutput: { [weak self] user in
                self?.currentUserSubject.send(user)
            })
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .eraseToAnyPublisher()
    }
    
    func updateUserProfile(profileImageData: Data) -> AnyPublisher<User, AuthentificationCoreError> {
        guard let user = currentUserSubject.value else {
            return Fail(error: AuthentificationCoreError.userInfoFetchFailed).eraseToAnyPublisher()
        }
        
        return apiService.requestPublisher(Endpoint.updateProfile(userID: user.id, image: profileImageData), UpdateProfileDTO.Response.self)
            .map {
                return User(id: user.id, nickname: user.nickname, smsVerificationToken: user.smsVerificationToken, createdAt: user.createdAt, imageURL: $0.profileImageURL)
            }
            .handleEvents(receiveOutput: { [weak self] user in
                self?.currentUserSubject.send(user)
            })
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .eraseToAnyPublisher()
    }
    
    func deleteUserProfile() -> AnyPublisher<Bool, AuthentificationCoreError> {
        guard let user = currentUserSubject.value else {
            return Fail(error: AuthentificationCoreError.userInfoFetchFailed).eraseToAnyPublisher()
        }
        
        return apiService.requestPublisher(Endpoint.deleteProfile(userID: user.id), EmptyDTO.Response.self)
            .map { _ in true }
            .handleEvents(receiveOutput: { [weak self] isSuccess in
                if isSuccess {
                    let user = User(id: user.id, nickname: user.nickname, smsVerificationToken: user.smsVerificationToken, createdAt: user.createdAt, imageURL: nil)
                    self?.currentUserSubject.send(user)
                }
            })
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .eraseToAnyPublisher()
    }
    
    func updateNickname(_ nickname: String) -> AnyPublisher<Bool, AuthentificationCoreError> {
        guard let user = currentUserSubject.value else {
            return Fail(error: AuthentificationCoreError.userInfoFetchFailed).eraseToAnyPublisher()
        }
        
        let dto = UpdateNicknameDTO.Request(nickname: nickname)
        
        return apiService.requestPublisher(Endpoint.updateNickname(userID: user.id, dto: dto), EmptyDTO.Response.self)
            .map { _ in true }
            .handleEvents(receiveOutput: { [weak self] isSuccess in
                if isSuccess {
                    let user = User(id: user.id, nickname: nickname, smsVerificationToken: user.smsVerificationToken, createdAt: user.createdAt, imageURL: user.imageURL)
                    self?.currentUserSubject.send(user)
                }
            })
            .mapError { AuthentificationCoreError.networkRequestFailed($0) }
            .eraseToAnyPublisher()
    }
}

// MARK: - AuthentificationMediationProtocol Conformation
extension AuthentificationCore: AuthentificationMediationProtocol {
    func loadCurrentUser() {
        guard let userIDString = UserDefaults.standard.string(forKey: AppStorageKey.currentUserID),
              let userID = UInt64(userIDString)
        else {
            currentUserSubject.send(nil)
            _pendingSocialUserID = nil
            isRegistrationNeededSubject.send(false)
            return
        }
        
        apiService
            .requestPublisher(Endpoint.readUserInfo(userID: userID), ReadUserInfoDTO.Response.self)
            .map { $0.toEntity() }
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure:
                    UserDefaults.standard.removeObject(forKey: AppStorageKey.currentUserID)
                    self?.currentUserSubject.send(nil)
                    self?._pendingSocialUserID = nil
                    self?.isRegistrationNeededSubject.send(false)
                }
            } receiveValue: { [weak self] user in
                let isFullyRegistered = user.nickname != nil
                
                if isFullyRegistered {
                    // 닉네임까지 모두 설정된 회원정보가 발행된 경우
                    self?.currentUserSubject.send(user)
                    self?._pendingSocialUserID = nil
                    self?.isRegistrationNeededSubject.send(false)
                } else {
                    // 기가입자이나 프로필 설정이 완료되지 않은 경우
                    self?._pendingSocialUserID = user.id
                    self?.currentUserSubject.send(nil)
                    self?.isRegistrationNeededSubject.send(true)
                }
            }
            .store(in: &cancellables)
    }
}
