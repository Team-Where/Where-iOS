//
//  AnnouncementViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/28/25.
//

import Foundation
import Combine
import Swinject

final class AnnouncementViewModel: ObservableObject {
    @Published var navigationType: NavigationType?
    @Published var announcements = [Announcement]()
    
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
                self?.announcements = dict.values
                    .sorted { $0.date > $1.date }
                    .filter { $0.type == .common }
            }
            .store(in: cancellableBag, key: "Announcements")
    }
}

// MARK: - Nested Types
extension AnnouncementViewModel {
    /// 공지사항 화면에서 라우팅 가능한 네비게이션패스의 종류
    enum NavigationType: Hashable {
        /// FAQ 및 공지사항 작성 화면
        case editAnnouncement
    }
}
