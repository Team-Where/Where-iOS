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
    /// 알림 읽음 여부
    let isRead: Bool
    /// 알림 종류
    let type: NotificationType
}

/// 알림 종류
enum NotificationType: Int {
    /// 장소 추가
    case placeAdded = 101
    /// 장소 삭제
    case placeDeleted = 103
    /// 장소 Pick
    case placePicked = 104
    /// 장소 좋아요수 변경
    case placeLikesUpdated = 105
    /// 같이 찾은 장소
    case placeSimulaneouslyPicked = 106
    /// 일정 추가
    case scheduleAdded = 201
    /// 일정 변경
    case scheduleUpdated = 202
    /// 일정 삭제
    case scheduleDeleted = 203
    /// 코멘트 추가
    case commentAdded = 301
    /// 코멘트 수정
    case commentUpdated = 302
    /// 코멘트 삭제
    case commentDeleted = 303
    /// 모임 참가신청 수락
    case meetingInvitationAccepted = 404
    /// 앱내 모임 초대
    case inviteMeetingInApp = 405
}
