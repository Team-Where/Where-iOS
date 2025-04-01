//
//  AuthentificationCore.swift
//  Where
//
//  Created by Swain Yun on 2/28/25.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKUser
import KakaoSDKAuth
import NidThirdPartyLogin
import AuthenticationServices
import Combine
import Moya

protocol AuthentificationCoreProtocol {
    /// 사용자 정보
    var user: AnyPublisher<User?, AuthentificationCoreError> { get }
    
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
}

enum AuthentificationCoreError: Error {
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
}

final class AuthentificationCore: NSObject, ObservableObject {
    struct Constants {
        static let currentProviderUserDefaultsKey: String = "currentProvider"
        static let currentUserIdUserDefaultsKey: String = "currentUserId"
    }
    
    @Published var _user: User?
    
    var isLoginNeeded: Bool { _user == nil }
    
    private var currentProvider: AuthentificationProvider? {
        get {
            guard let provider = UserDefaults.standard.string(forKey: Constants.currentProviderUserDefaultsKey) else { return nil }
            return AuthentificationProvider(identifier: provider)
        }
        
        set {
            UserDefaults.standard.setValue(newValue?.identifier, forKey: Constants.currentProviderUserDefaultsKey)
        }
    }
    private var currentUserId: Int64? {
        get {
            guard let userIdString = UserDefaults.standard.string(forKey: Constants.currentUserIdUserDefaultsKey) else { return nil }
            return Int64(userIdString)
        }
        
        set {
            UserDefaults.standard.setValue(newValue?.description, forKey: Constants.currentUserIdUserDefaultsKey)
        }
    }
    
    private let kakaoAPI: UserApi
    private let naverAPI: NidOAuth
    private let networkService: NetworkServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private let decoder: JSONDecoder = .init()
    private let encoder: JSONEncoder = .init()
    private let userSubject = PassthroughSubject<User?, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        networkService: NetworkServiceProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.kakaoAPI = .shared
        self.naverAPI = .shared
        self.networkService = networkService
        self.tokenStorage = tokenStorage
        super.init()
        _configureKakaoAPI()
        _configureNaverAPI(self.naverAPI)
        subscribe()
    }
    
    private func subscribe() {
        userSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?._user = user
            }
            .store(in: &cancellables)
    }
}

// MARK: KakaoSDK Related
extension AuthentificationCore {
    private func _configureKakaoAPI() {
        guard let key = Bundle.fetchKey(provider: .kakao) else {
            fatalError("카카오SDK 초기화 실패: 잘못된 앱키")
        }
        
        KakaoSDK.initSDK(appKey: key)
    }
    
    private func handleKakaoLoginResult(token: OAuthToken?, error: Error?) {
        if let error = error {
            #if DEBUG
            print(error)
            #endif
            userSubject.send(nil)
            return
        }
        
        kakaoAPI.me { [weak self] user, error in
            // TODO: 에러 핸들링 강화 필요
            if let error = error {
                #if DEBUG
                print(error)
                #endif
                self?.userSubject.send(nil)
                return
            }
            
            guard let userId = user?.id else {
                self?.userSubject.send(nil)
                return
            }
            
            let email = user?.kakaoAccount?.email
            let nickname = user?.kakaoAccount?.profile?.nickname
            
            let userCredential = UserCredential(provider: .kakao, ci: String(userId), email: email, nickname: nickname)
            
            // TODO: 서버 통신 (네트워킹 모델 확정 후 구현)
            
            self?.userSubject.send(User())
        }
    }
    
    private func handleKakaoLogout(completion: @escaping (Result<Void, Error>) -> Void) {
        kakaoAPI.logout { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: NaverSDK Related
extension AuthentificationCore {
    private func _configureNaverAPI(_ naver: NidOAuth) {
        naver.initialize()
        naver.setLoginBehavior(.appPreferredWithInAppBrowserFallback)
    }
    
    private func handleNaverLoginResult(_ result: Result<LoginResult, NidError>) {
        switch result {
        case .success(let tokens):
            guard tokens.accessToken.isExpired == false else {
                // 토큰 만료 시 재귀호출
                return loginWithNaver()
            }
            
            naverAPI.getUserProfile(accessToken: tokens.accessToken.tokenString) { result in
                switch result {
                case .success(let entity):
                    guard let id = entity["id"] else { return }
                    let email = entity["email"]
                    let nickname = entity["nickname"]
                    let userCredential = UserCredential(provider: .naver, ci: id, email: email, nickname: nickname)
                case .failure(let error):
                    print(error)
                }
            }
        case .failure(let error):
            print(error)
        }
    }
}

// MARK: AuthentificationCoreProtocol Conformation
extension AuthentificationCore: AuthentificationCoreProtocol {
    var user: AnyPublisher<User?, AuthentificationCoreError> {
        $_user
            .map { $0 }
            .setFailureType(to: AuthentificationCoreError.self)
            .eraseToAnyPublisher()
    }
    
    func handleOpenURL(_ provider: AuthentificationProvider, _ url: URL) {
        switch provider {
        case .apple, .custom:
            break
        case .kakao:
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        case .naver:
            _ = naverAPI.handleURL(url)
        }
    }
    
    
    func loginWithApple(auth: ASAuthorization) {
        switch auth.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userId = appleIDCredential.user
            let email = appleIDCredential.email
            let nickname = appleIDCredential.fullName?.nickname
            let userCredential = UserCredential(provider: .apple, ci: userId, email: email, nickname: nickname)
            
            // TODO: 서버 통신 (네트워킹 모델 확정 후 구현)
            
        default:
            // TODO: 에러 핸들링 필요
            break
        }
    }
    
    func loginWithKakao() {
        let nonce = UUID().uuidString
        
        if UserApi.isKakaoTalkLoginAvailable() {
            kakaoAPI.loginWithKakaoTalk(nonce: nonce) { [weak self] token, error in
                self?.handleKakaoLoginResult(token: token, error: error)
            }
        } else {
            kakaoAPI.loginWithKakaoAccount(nonce: nonce) { [weak self] token, error in
                self?.handleKakaoLoginResult(token: token, error: error)
            }
        }
    }
    
    func loginWithNaver() {
        naverAPI.requestLogin { [weak self] result in
            self?.handleNaverLoginResult(result)
        }
    }
    
    func login(email: String, password: String) {
        // TODO: 서버 통신 (네트워킹 모델 확정 후 구현)
        
        userSubject.send(User())
    }
    
    func logout() {
        guard let provider = currentProvider else { return }
        
        switch provider {
        case .apple, .naver:
            break
        case .kakao:
            handleKakaoLogout { [weak self] result in
                switch result {
                case .success:
                    self?.currentProvider = nil
                    self?.currentUserId = nil
                    self?.userSubject.send(nil)
                case .failure(let error):
                    print(error)
                }
            }
        case .custom:
            handleCustomLogout()
        }
    }
    
    private func handleCustomLogout() {
        // TODO: 서버 통신 (네트워킹 모델 확정 후 구현)
        currentProvider = nil
        currentUserId = nil
        userSubject.send(nil)
    }
}
