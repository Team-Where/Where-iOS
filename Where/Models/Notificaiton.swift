//
//  Notificaiton.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import Foundation

/// 공지 정보
struct Notification: Identifiable {
    /// 공지 고유 식별자
    let id: UInt64
    /// 공지 제목
    let title: String
    /// 공지 내용
    let content: String
    /// 공지 종류
    let type: NotificationType
}

/// 공지 종류
enum NotificationType: Int {
    /// 일반공지
    case notification = 0
    /// Q&A
    case QandA
}
