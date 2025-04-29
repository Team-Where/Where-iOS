//
//  NotificationListViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/29/25.
//

import Foundation
import Swinject
import Combine

final class NotificationListViewModel: ObservableObject {
    @Published var notifications = [Notification]()
    
    private let notificationCore: NotificationCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.notificationCore = resolver.resolve(NotificationCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        notificationCore.notifications
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] dict in
                self?.notifications = dict.values.sorted { $0.date > $1.date }
            }
            .store(in: &cancellables)
    }
}
