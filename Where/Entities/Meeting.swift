//
//  Meeting.swift
//  Where
//
//  Created by Swain Yun on 1/23/25.
//

import Foundation

/// 모임 정보
struct Meeting: Identifiable {
    /// 식별자
    let id: UInt64
    /// 제목
    let title: String
    /// 모임 소개 등 부가설명
    let description: String
    /// 모임 대표 이미지 URL
    let imageURL: URL?
    /// 생성일시
    let createdAt: Date?
    /// 최근 수정일시
    let updatedAt: Date?
    /// 모임 일정 날짜
    let scheduleDate: Date?
    /// 모임 일정 시간
    let scheduleTime: Date?
    /// 공유 링크
    let shareLink: URL?
    /// 활성화 여부
    var isFinished: Bool
    
    init(
        id: UInt64,
        title: String,
        description: String,
        imageURL: URL? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        scheduleDate: Date? = nil,
        scheduleTime: Date? = nil,
        shareLink: URL? = nil,
        isFinished: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.scheduleDate = scheduleDate
        self.scheduleTime = scheduleTime
        self.shareLink = shareLink
        self.isFinished = isFinished
    }
}

/// 모임 참여 인원
struct Participant {
    /// 모임 초대자 식별자
    let inviterId: UInt64
    /// 모임 참가자 식별자
    let participantId: UInt64
    /// 초대 요청 수락 여부
    let status: Bool
    /// 초대 요청 일시
    let createdAt: Date
    /// 초대 요청 수정일시
    let updatedAt: Date
}
