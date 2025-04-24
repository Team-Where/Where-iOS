//
//  NotificationCore.swift
//  Where
//
//  Created by Swain Yun on 4/17/25.
//

import Foundation
import Combine

protocol NotificationCoreProtocol: CoreProtocol {
    /// 알림 목록
    var notifications: AnyPublisher<[UInt64: Notification], NotificationCoreError> { get }
    
    /// 알림 읽음 처리
    func markNotificationAsRead(id: UInt64)
    
    /// FCM/APNs로부터 전달된 원시 페이로드 처리
    func handleReceivedNotificaitonPayload(_ payload: [AnyHashable: Any])
}

protocol NotificationMediationProtocol {
    
}

enum NotificationCoreError: Error {
    
}

final class NotificationCore {
    weak var mediator: Notifiable?
    
    private var _notifications = [UInt64: Notification]()
    
    private let notificationsSubject = CurrentValueSubject<[UInt64: Notification], NotificationCoreError>([:])
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    private func subscribe() {
        notificationsSubject
            .sink { completion in
                // TODO: 에러 핸들링 강화
            } receiveValue: { [weak self] dict in
                self?._notifications = dict
            }
            .store(in: &cancellables)
    }
}

// MARK: - NotificationCoreProtocol Conformation
extension NotificationCore: NotificationCoreProtocol {
    var notifications: AnyPublisher<[UInt64 : Notification], NotificationCoreError> {
        notificationsSubject.eraseToAnyPublisher()
    }
    
    func markNotificationAsRead(id: UInt64) {
        guard let notification = notificationsSubject.value[id] else { return }
        var notifications = notificationsSubject.value
        notifications[id] = Notification(
            id: notification.id,
            title: notification.title,
            content: notification.content,
            date: notification.date,
            isRead: true,
            type: notification.type
        )
        notificationsSubject.send(notifications)
    }
    
    func handleReceivedNotificaitonPayload(_ payload: [AnyHashable: Any]) {
        
    }
}

// MARK: - NotificationMediationProtocol Conformation
extension NotificationCore: NotificationMediationProtocol {
    func saveNotification(_ notification: Notification) {
        
    }
}
