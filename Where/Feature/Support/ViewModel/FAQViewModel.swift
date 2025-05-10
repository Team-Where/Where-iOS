//
//  FAQViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/28/25.
//

import Foundation
import Combine
import Swinject

final class FAQViewModel: ObservableObject {
    @Published var navigationType: NavigationType?
    @Published var faqs = [Announcement]()
    
    private let supportCore: SupportCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.supportCore = resolver.resolve(SupportCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        supportCore.announcements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dict in
                self?.faqs = dict.values
                    .sorted { $0.date > $1.date }
                    .filter { $0.type == .FAQ }
            }
            .store(in: cancellableBag, key: "Announcements")
    }
}

// MARK: - Nested Types
extension FAQViewModel {
    /// 모임정보 상세 화면에서 라우팅 가능한 네비게이션패스의 종류
    enum NavigationType: Hashable {
        /// FAQ 및 공지사항 작성 화면
        case editAnnouncement
        /// 1:1 문의 작성 화면
        case editInquiry
    }
}

// MARK: - Interfaces
extension FAQViewModel {
    func presentEditInquiryView() {
        navigationType = .editInquiry
    }
}
