//
//  AnnouncementViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/28/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class AnnouncementViewModel {
    private(set) var announcements = [Announcement]()
    
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
