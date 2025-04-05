//
//  Announcement.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import Foundation

/// 공지 정보
struct Announcement: Identifiable {
    /// 공지 고유 식별자
    let id: UInt64
    /// 공지 제목
    let title: String
    /// 공지 내용
    let content: String
    /// 공지 발행 시간
    let date: Date
    /// 공지 종류
    let type: AnnouncementType
}

/// 공지 종류
enum AnnouncementType: Int {
    /// 일반공지
    case common = 0
    /// FAQ
    case FAQ
}
