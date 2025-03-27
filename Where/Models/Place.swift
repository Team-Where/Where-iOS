//
//  Place.swift
//  Where
//
//  Created by Swain Yun on 1/10/25.
//

import Foundation

/// 모임 장소
struct Place: Identifiable {
    /// 모임 고유 식별자
    let id: UInt64
    /// 장소 등록자의 식별자
    let userId: UInt64
    /// 참여 중인 모임 식별자
    let meetingId: UInt64
    /// 장소명
    let name: String
    /// 장소의 주소
    let address: String
    /// 장소정보등록일시
    let createdAt: Date
    /// 장소정보수정일시
    let updatedAt: Date
    /// 좋아요 개수
    let likesCount: UInt64
    /// 장소 선택 여부
    let status: PickedState
    /// 외부 지도앱 장소 링크
//    let links: PlaceLinks
    /// 장소에 대한 코멘트
    let comments: [Comment]
}

/// 장소 선택 여부
enum PickedState {
    /// 선택함
    case picked
    /// 선택안함
    case unpicked
}

/// 장소 링크
struct PlaceLinks {
    let naverLink: URL
    let kakaoLink: URL
}
