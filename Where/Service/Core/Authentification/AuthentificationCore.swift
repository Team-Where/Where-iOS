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
    
    private let userSubject = CurrentValueSubject<User?, AuthentificationCoreError>(nil)
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
    
    weak var mediator: CoreMediatorProtocol?
    
    private let tokenStorage: TokenStorageProtocol
    private let strategyContext = AuthentificationStrategyContext()
    private let decoder: JSONDecoder = .init()
    private let encoder: JSONEncoder = .init()
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
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print("AuthentificationCore Error: \(error)")
                    #endif
                }
            } receiveValue: { [weak self] user in
                self?._user = user
                
                guard let user else {
                    // TODO: 로그아웃 상황 중재
                    // self?.mediator?.notify(event: .userDidLogout(id: ))
                    self?._user = nil
                    self?.currentUserId = nil
                    return
                }
                
                self?.currentUserId = user.id
                self?.mediator?.notify(event: .userDidLogin(id: user.id))
            }
            .store(in: &cancellables)
        
        strategyContext.credentialSubject
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.userSubject.send(completion: .failure(error))
                }
            } receiveValue: { [weak self] credential in
                // TODO: 여기에 네트워킹 로직 작성
            }
            .store(in: &cancellables)
    }
}

// MARK: AuthentificationCoreProtocol Conformation
extension AuthentificationCore: AuthentificationCoreProtocol {
    var user: AnyPublisher<User?, AuthentificationCoreError> {
        userSubject.eraseToAnyPublisher()
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
        
        
        _Concurrency.Task { @MainActor in
            userSubject.send(PreviewHelper.shared.mockUser)
        }
//        strategyContext.login(by: .custom(email: email, password: password))
    }
    
    func logout() {
        
    }
}
