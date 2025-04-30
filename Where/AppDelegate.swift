//
//  AppDelegate.swift
//  Where
//
//  Created by Swain Yun on 4/30/25.
//

import UIKit
import Swinject
import UserNotifications

final class AppDelegate: NSObject {
    private var notificationCore: NotificationCoreProtocol!
    
    override init() {
        super.init()
    }
    
    func configure(resolver: Resolver) {
        self.notificationCore = resolver.resolve(NotificationCoreProtocol.self)!
    }
}

// MARK: - UIApplicationDelegate Conformation
extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // FirebaseApp.configure()
        // Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        Task { @MainActor in
            do {
                let isGranted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                if isGranted {
                    application.registerForRemoteNotifications()
                    UserDefaults.standard.set(true, forKey: AppStorageKey.shouldDisplayNotifications)
                } else {
                    UserDefaults.standard.set(false, forKey: AppStorageKey.shouldDisplayNotifications)
                }
            } catch {
                print(error)
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        // APNs 토큰 등록 실패 시 호출됨
        return
    }
    
    /// Background에서 푸시 알림을 수신했을 때 호출됨
    /// Non-sendable parameter type '[AnyHashable : Any]' cannot be sent from caller of protocol requirement 'application(_:didReceiveRemoteNotification:)' into nonisolated implementation; this is an error in the Swift 6 language mode
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        notificationCore.handleReceivedNotificationPayload(userInfo)
        return .newData
    }
}

// MARK: - UNUserNotificationCenterDelegate Conformation
extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Foreground에서 푸시 알림을 수신했을 때 호출됨
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        let shouldDisplayNotifications = UserDefaults.standard.bool(forKey: AppStorageKey.shouldDisplayNotifications)
        notificationCore.handleReceivedNotificationPayload(userInfo)
        return shouldDisplayNotifications ? [.banner, .badge, .sound] : []
    }
    
    /// Foreground 또는 Background에서 푸시 수신 후, 사용자가 터치하여 앱을 열었을 때 호출됨
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        guard let aps = userInfo["aps"] as? [String: Any],
              let alert = userInfo["alert"] as? [String: Any]
        else { return }
        
        // TODO: 코드로 알림 종류 파악 및 NotificationCore로 전달
    }
}

// MARK: - MessagingDelegate Conformation
//extension AppDelegate: MessagingDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        guard let fcmToken = fcmToken else { return }
//        // NotificationCore 통해서 fcmToken을 업데이트, 서버로 전달
//        
//        Messaging.messaging().token { token, error in
//            if let error = error {
//                print("Error Occured: FCM registration token. \(error)")
//            } else {
//                print("FCM registration Success: Received. \(token)")
//            }
//        }
//        
//        let dataDict: [String: String] = ["token", fcmToken]
//        NotificationCenter.default.post(
//            name: Notification.Name("FCMToken"),
//            object: nil,
//            userInfo: dataDict
//        )
//    }
//}
