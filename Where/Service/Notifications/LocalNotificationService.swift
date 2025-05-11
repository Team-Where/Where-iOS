//
//  LocalNotificationService.swift
//  Where
//
//  Created by BOMBSGIE on 5/11/25.
//

import Foundation
import UserNotifications

final class LocalNotificationService {
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    func setNotification(_ meeting: Meeting) {
        guard meeting.isFinished else { return }
        Hour.allCases.forEach {
            addNotification(meeting, hour: $0)
        }
    }
    
    func removeNotification(for meeting: Meeting) {
        let identifiers = Hour.allCases.map { "\(meeting.id)_\($0.message)"}
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

// MARK: - Nested Type

extension LocalNotificationService {
    enum Hour: CaseIterable {
        case twentyfour
        case one
        
        var timeInterval: TimeInterval {
            switch self {
            case .twentyfour:
                -24 * 60 * 60
            case .one:
                -1 * 60 * 60
            }
        }
        
        var message: String {
            switch self {
            case .twentyfour:
                "24시간"
            case .one:
                "1시간"
            }
        }
    }
}

// MARK: - Private

private extension LocalNotificationService {
    /// UNNotificationCenter에 알림 등록
    ///  - Parameters:
    ///     - meeting: 등록핢 모임
    ///     - hour: 내부적으로 사용될 24시간, 1시간.
    func addNotification(_ meeting: Meeting, hour: Hour) {
        guard let date = meeting.combinedSchedule?.addingTimeInterval(hour.timeInterval),
              date > .now
        else {
            return
        }
        
        let content = createContent(with: meeting, at: hour)
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "\(meeting.id)_\(hour.message)", content: content, trigger: trigger)
        userNotificationCenter.add(request)
    }
    
    /// 알림에 보여질 Content 설정
    func createContent(with meeting: Meeting, at hour: Hour) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = meeting.title
        content.body = "\(meeting.title) \(hour.message)전 입니다."
        content.sound = .default
        return content
    }
}
