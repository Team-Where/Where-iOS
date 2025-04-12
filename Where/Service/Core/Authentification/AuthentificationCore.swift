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
}

private extension AuthentificationCore {
    enum Constants: String {
        case currentUserIdUserDefaultsKey = "currentUserId"
    }
}

final class AuthentificationCore: NSObject, ObservableObject {
    @Published var _user: User?
    
    var isLoginNeeded: Bool { _user == nil }
    
    private var currentProvider: AuthentificationProvider?
    private var currentUserId: UInt64? {
        get {
            guard let userIdString = UserDefaults.standard.string(forKey: Constants.currentUserIdUserDefaultsKey.rawValue) else { return nil }
            return UInt64(userIdString)
        }
        
        set {
            UserDefaults.standard.setValue(newValue?.description, forKey: Constants.currentUserIdUserDefaultsKey.rawValue)
        }
    }
    
    private let tokenStorage: TokenStorageProtocol
    private let strategyContext = AuthentificationStrategyContext()
    private let decoder: JSONDecoder = .init()
    private let encoder: JSONEncoder = .init()
    private let userSubject = PassthroughSubject<User?, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        tokenStorage: TokenStorageProtocol
    ) {
        self.tokenStorage = tokenStorage
        super.init()
        subscribe()
    }
    
    private func subscribe() {
        userSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?._user = user
            }
            .store(in: &cancellables)
        
        strategyContext.credential
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.userSubject.send(nil)
                }
            } receiveValue: { [weak self] credential in
                // TODO: 여기에 네트워킹 로직 작성
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
        
    }
}
