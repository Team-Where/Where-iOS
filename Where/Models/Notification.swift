//
//  Notification.swift
//  Where
//
//  Created by Swain Yun on 3/22/25.
//

import Foundation

/// 알림 정보
struct Notification: Identifiable {
    /// 알림 식별자
    let id: UInt64
    /// 알림 제목
    let title: String
    /// 알림 내용
    let content: String
    /// 알림 발행 시간
    let date: Date
}
