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
    
    /// 앱 실행 시 FCM 토큰 설정
    func setFCMToken(_ fcmToken: String)
}

protocol NotificationMediationProtocol {
    /// 현재 사용자 식별자를 설정, 중재자에 의해 호출됨
    func setCurrentUserID(_ id: UInt64?)
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
    private var currentUserID: UInt64?
    private var fcmToken: String?
    
    private let notificationsSubject = CurrentValueSubject<[UInt64: Notification], Never>([:])
    
    private let cancellableBag = CancellableBag()
    
    private let apiService: APIServable
    private let localNotificationService: LocalNotificationService
    
    init(
        apiService: APIServable,
        _ localNotificationService: LocalNotificationService
    ) {
        self.apiService = apiService
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
    
    /// FCM 토큰 등록
    private func registerFCMToken(_ fcmToken: String) {
        self.fcmToken = fcmToken
        print("FCM 토큰 등록 요청!!!!!!")
        guard let userID = currentUserID else { return }
        
        let dto = FCMRegisterDTO.Request(fcmToken: fcmToken)
        apiService.requestVoidPublisher(Endpoint.registerFCMToken(userID: userID, dto: dto))
            .sink { completion in
                switch completion {
                case .finished: print("FCM Token 등록 완료: \(fcmToken)")
                case .failure(let error): print("FCM Token 등록 중 에러: \(error)")
                }
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
    }
    
    /// FCM 토큰 삭제
    private func unregisterFCMToken() {
        print("FCM 토큰 삭제 요청!!!!!!")
        guard let userID = currentUserID else { return }
        // Note: FCMRegisterDTO를 이용해 nil을 담아 요청하면 FCM 토큰 삭제하도록 동작함
        let dto = FCMRegisterDTO.Request(fcmToken: nil)
        apiService.requestVoidPublisher(Endpoint.registerFCMToken(userID: userID, dto: dto))
            .sink { completion in
                switch completion {
                case .finished: print("FCM Token 삭제 완료")
                case .failure(let error): print("FCM Token 삭제 중 에러: \(error)")
                }
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
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
        guard let payload = payload as? [String: String] else {
            return print("알림 캐스팅 실패")
        }
        print(payload)
    }
    
    func setFCMToken(_ fcmToken: String) {
        self.fcmToken = fcmToken
        
        guard currentUserID != nil else { return }
        registerFCMToken(fcmToken)
    }
}

// MARK: - NotificationMediationProtocol Conformation
extension NotificationCore: NotificationMediationProtocol {
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
        
        guard let fcmToken = fcmToken else { return }
        registerFCMToken(fcmToken)
    }
    
    func userDidLogout() {
        unregisterFCMToken()
        currentUserID = nil
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
