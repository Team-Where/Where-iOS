//
//  FAQViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/28/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class FAQViewModel {
    private(set) var faqs = [Announcement]()
    
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

// MARK: - Interfaces
extension FAQViewModel {
    
}
