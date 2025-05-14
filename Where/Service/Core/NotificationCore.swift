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
    var notifications: AnyPublisher<[UInt64: Notification], Never> { get }
    
    /// 알림 읽음 처리
    func markNotificationAsRead(id: UInt64)
    
    /// FCM/APNs로부터 전달된 원시 페이로드 처리
    func handleReceivedNotificationPayload(_ payload: [AnyHashable: Any])
}

protocol NotificationMediationProtocol {
    /// 사용자 로그아웃 시 작업 수행을 지시, 중재자에 의해 호출됨
    func userDidLogout()
    
    func updateNotifications(for meeting: Meeting)
    
    func removeNotifications(for meetingID: UInt64)
    
}

enum NotificationCoreError: Error {
    
}

final class NotificationCore {
    weak var mediator: Notifiable?
    
    private var _notifications = [UInt64: Notification]()
    
    private let notificationsSubject = CurrentValueSubject<[UInt64: Notification], Never>([:])
    
    private let cancellableBag = CancellableBag()
    
    private let localNotificationService: LocalNotificationService
    
    init(_ localNotificationService: LocalNotificationService) {
        self.localNotificationService = localNotificationService
        subscribe()
    }
    
    private func subscribe() {
        notificationsSubject
            .sink { completion in
                
            } receiveValue: { [weak self] dict in
                self?._notifications = dict
            }
            .store(in: cancellableBag, key: "NotificationsSubject")
    }
}

// MARK: - NotificationCoreProtocol Conformation
extension NotificationCore: NotificationCoreProtocol {
    var notifications: AnyPublisher<[UInt64 : Notification], Never> {
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
    
    func handleReceivedNotificationPayload(_ payload: [AnyHashable: Any]) {
        
    }
}

// MARK: - NotificationMediationProtocol Conformation
extension NotificationCore: NotificationMediationProtocol {
    func userDidLogout() {
        notificationsSubject.send([:])
    }
    
    func removeNotifications(for meetingID: UInt64) {
        localNotificationService.removeNotification(for: meetingID)
    }
    
    func updateNotifications(for meeting: Meeting) {
        localNotificationService.removeNotification(for: meeting.id)
        localNotificationService.setNotification(meeting)
    }
}
