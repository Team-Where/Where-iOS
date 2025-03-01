//
//  AuthentificationService.swift
//  Where
//
//  Created by Swain Yun on 2/28/25.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKUser
import KakaoSDKAuth
import NaverThirdPartyLogin
import AuthenticationServices
import Combine

protocol AuthentificationServiceProtocol: ObservableObject {
    /// 사용자 정보
    var user: User? { get }
    
    /// Redirection URL Handling
    func handleOpenURL(_ provider: AuthentificationProvider, _ url: URL) async
    
    /// 애플 로그인
    @MainActor
    func loginWithApple(auth: ASAuthorization)
    
    /// 카카오 로그인
    @MainActor
    func loginWithKakao()
    
    /// 네이버 로그인
    @MainActor
    func loginWithNaver()
    
    /// 자체 로그인
    @MainActor
    func login(email: String, password: String)
    
    /// 로그아웃
    func logout()
}

enum AuthentificationServiceError: Error {
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

@MainActor
final class AuthentificationService: NSObject, ObservableObject {
    struct Constants {
        static let currentProviderUserDefaultsKey: String = "currentProvider"
        static let currentUserIdUserDefaultsKey: String = "currentUserId"
    }
    
    @Published var user: User?
    
    private let kakaoAPI: UserApi
    private let naverAPI: NaverThirdPartyLoginConnection
    private let networkService: NetworkServiceProtocol
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
    
    private let userSubject = PassthroughSubject<User?, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkServiceProtocol) {
        self.kakaoAPI = .shared
        self.naverAPI = .getSharedInstance()
        self.networkService = networkService
        super.init()
        _configureKakaoAPI()
        _configureNaverAPI(self.naverAPI)
        subscribe()
    }
    
    private func subscribe() {
        userSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
    }
}

// MARK: KakaoSDK Related
extension AuthentificationService {
    private func _configureKakaoAPI() {
        guard let key = Bundle.fetchKey(provider: .kakao) else {
            fatalError("카카오SDK 초기화 실패: 잘못된 앱키")
        }
        
        KakaoSDK.initSDK(appKey: key)
    }
    
    private func handleKakaoLoginResult(token: OAuthToken?, error: Error?) {
        if let error = error {
            userSubject.send(nil)
            return
        }
        
        kakaoAPI.me { [weak self] user, error in
            // TODO: 에러 핸들링 강화 필요
            if let error = error {
                self?.userSubject.send(nil)
                return
            }
            
            guard let userId = user?.id,
                  let email = user?.kakaoAccount?.email,
                  let nickname = user?.kakaoAccount?.profile?.nickname
            else {
                self?.userSubject.send(nil)
                return
            }
            
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

// MARK: NaverThirdPartyLoginConnectionDelegate Conformation, NaverSDK Related
extension AuthentificationService: @preconcurrency NaverThirdPartyLoginConnectionDelegate {
    private func _configureNaverAPI(_ naver: NaverThirdPartyLoginConnection) {
        guard let key = Bundle.fetchKey(provider: .naver) else {
            fatalError("네이버SDK 초기화 실패: 잘못된 앱키")
        }
        
        naver.isNaverAppOauthEnable = true
        naver.isInAppOauthEnable = true
        naver.setOnlyPortraitSupportInIphone(true)
        naver.serviceUrlScheme = "where.naver.login"
        naver.consumerKey = "EM6n_yrMpySUgUsU_d4Z"
        naver.consumerSecret = key
        naver.appName = "어디"
        naver.delegate = self
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        // TODO: 획득한 토큰을 사용해 네이버로 사용자 정보 요청 로직 구현
        guard naverAPI.isValidAccessTokenExpireTimeNow() == false else { return }
        
        guard let tokenType = naverAPI.tokenType,
              let accessToken = naverAPI.accessToken
        else { return }
        
        // TODO: 서버 통신 (네트워킹 모델 확정 후 구현)
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        // TODO: 토큰 갱신될 때 필요한 작업 구현
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        // TODO: 로그아웃 등으로 토큰이 삭제 됐을 때 필요한 작업 구현
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: (any Error)!) {
        // TODO: 필요한 에러 핸들링 구현
    }
}

// MARK: AuthentificationServiceProtocol Conformation
extension AuthentificationService: @preconcurrency AuthentificationServiceProtocol {
    func handleOpenURL(_ provider: AuthentificationProvider, _ url: URL) {
        switch provider {
        case .apple, .custom:
            break
        case .kakao:
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        case .naver:
            naverAPI.receiveAccessToken(url)
        }
    }
    
    
    func loginWithApple(auth: ASAuthorization) {
        switch auth.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userId = appleIDCredential.user
            let email = appleIDCredential.email
            
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
        naverAPI.requestThirdPartyLogin()
    }
    
    func login(email: String, password: String) {
        // TODO: 서버 통신 (네트워킹 모델 확정 후 구현)
        // do {
        //     let user = try await networkService.data(endpoint: 로그인 요청)
        //     continuation.resume(returning: .success(User()))
        //     currentProvider = .kakao
        //     currentUser = user
        // } catch {
        //     continuation.resume(returning: .failure(error))
        // }
        
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
                    self?.userSubject.send(nil)
                case .failure(let error):
                    print(error)
                }
            }
        case .custom:
            handleCustomLogout()
        }
        
        currentProvider = nil
        currentUserId = nil
    }
    
    private func handleCustomLogout() {
        Task {
            // TODO: 서버 통신 (네트워킹 모델 확정 후 구현)
            userSubject.send(nil)
        }
    }
    
    func currentUser() async -> User? {
        nil
    }
}
