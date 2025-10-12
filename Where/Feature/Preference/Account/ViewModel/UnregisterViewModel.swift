//
//  UnregisterViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/28/25.
//

import Foundation
import Combine
import Swinject

final class UnregisterViewModel: ObservableObject {
    @Published var selectedUnregisterReason: UnregisterReasonType = .infrequentUse
    @Published var unregisterStep: UnregisterStep = .submitUnregisterReason
    @Published var isSheetPresented: Bool = false
    @Published private(set) var isProcessing: Bool = false
    
    private var isLoginNeeded: Bool = false
    
    private let authCore: AuthentificationCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.authCore = resolver.resolve(AuthentificationCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        authCore.currentUser
            .sink { [weak self] completion in
                guard case .failure = completion else { return }
                self?.isLoginNeeded = true
            } receiveValue: { [weak self] user in
                self?.isLoginNeeded = user == nil
            }
            .store(in: cancellableBag, key: "CurrentUser")
    }
}

// MARK: - Nested Types
extension UnregisterViewModel {
    struct Constants {
        static let confirmationTitleScript: String = "잠깐만요"
        static let confirmationContentScript: String = "탈퇴 시 계정 및 이용 기록은 모두 삭제되며,\n삭제된 데이터는 복구가 불가능합니다.\n또한 탈퇴 후 동일 계정으로 재가입시\n제한을 받을 수 있습니다.\n탈퇴를 진행할까요?"
    }
    
    enum UnregisterReasonType: String, RadioButtonSelection {
        case infrequentUse = "사용을 잘 안해서"
        case frequentErrors = "잦은 오류, 장애가 발생해서"
        case difficultyOfUse = "이용 방법이 어려워서"
        case other = "기타"
        
        var title: String {
            self.rawValue
        }
    }
    
    /// 회원탈퇴 과정의 단계를 의미합니다.
    enum UnregisterStep {
        /// 탈퇴 사유 제출
        case submitUnregisterReason
        /// 탈퇴 처리 완료
        case unregisterComplete
    }
}

// MARK: - Interfaces
extension UnregisterViewModel {
    func presentUnregisterConfirmationSheet() {
        isSheetPresented = true
    }
    
    func dismissUnregisterConfirmationSheet() {
        isSheetPresented = false
    }
    
    func unregister() {
        guard isLoginNeeded == false else { return }
        
        isProcessing = true
        cancellableBag[#function] = authCore.unregister()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] _ in
                self?.isProcessing = false
                self?.isSheetPresented = false
                self?.unregisterStep = .unregisterComplete
                self?.selectedUnregisterReason = .infrequentUse
            }
    }
}
