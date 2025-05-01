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
    
    /// 회원가입
    func register(email: String, password: String, nickname: String, profileImageData: Data?)
    
    /// 회원탈퇴
    func unregister()
    
    /// 프로필 수정
    func updateUserProfile(nickname: String, profileImageData: Data?)
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
    
    private let currentUserSubject = CurrentValueSubject<User?, AuthentificationCoreError>(nil)
    
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
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print("AuthentificationCore Error: \(error)")
                    #endif
                }
            } receiveValue: { [weak self] user in
                guard let user else {
                    // 로그아웃 로직 작성
                    // 1. 사용자가 로그아웃하여 사용자 정보가 없어졌음을 중재자를 통해 알림
                    // 2. 토큰 및 내부 데이터풀 정리
//                    if let currentUserID = self?.currentUserId {
//                        self?.mediator?.notify(event: .userDidLogout(id: currentUserID))
//                    }
                    return
                }
                // TODO: 관리자 계정인지 아닌지 파악 여부 후 로직 구현
//                self?.mediator?.notify(event: .userDidLogin(id: user.id, isAdmin: ))
                UserDefaults.standard.setValue(String(user.id), forKey: AppStorageKey.currentUserID)
            }
            .store(in: &cancellables)
        
        strategyContext.credentialSubject
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.currentUserSubject.send(completion: .failure(error))
                }
            } receiveValue: { [weak self] credential in
                // TODO: 여기에 네트워킹 로직 작성
            }
            .store(in: &cancellables)
    }
}

// MARK: AuthentificationCoreProtocol Conformation
extension AuthentificationCore: AuthentificationCoreProtocol {
    var currentUser: AnyPublisher<User?, AuthentificationCoreError> {
        currentUserSubject.eraseToAnyPublisher()
    }
    
    var isLoginNeeded: Bool {
        _currentUser == nil
    }
    
    func handleOpenURL(_ provider: AuthentificationProvider, _ url: URL) {
        strategyContext.handleOpenURL(url)
    }
    
    func loginWithApple(auth: ASAuthorization) {
        strategyContext.login(by: .apple(auth: auth))
    }
    
    func loginWithKakao() {
        strategyContext.login(by: .kakao)
    }
    
    func loginWithNaver() {
        strategyContext.login(by: .naver)
    }
    
    func login(email: String, password: String) {
        strategyContext.login(by: .custom(email: email, password: password))
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
    
    func updateUserProfile(nickname: String, profileImageData: Data?) {
        
    }
}

// MARK: - AuthentificationMediationProtocol Conformation
extension AuthentificationCore: AuthentificationMediationProtocol {
    func loadCurrentUser() {
        guard let userIDString = UserDefaults.standard.string(forKey: AppStorageKey.currentUserID),
              let userID = UInt64(userIDString)
        else {
            return currentUserSubject.send(completion: .failure(.autoLoginFailed))
        }
        
        apiService
            .requestPublisher(Endpoint.readUserInfo(userID: userID), ReadUserInfoDTO.Response.self)
            .map { $0.toEntity() }
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] user in
                self?.currentUserSubject.send(user)
            }
            .store(in: &cancellables)
    }
}
