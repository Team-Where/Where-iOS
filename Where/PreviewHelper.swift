//
//  PreviewHelper.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import SwiftUI
import Swinject

@MainActor
final class PreviewHelper {
    static let shared = PreviewHelper()
    
    let resolver: Resolver
    
    lazy var mockUser = User()
    
    lazy var mockFriends: [FriendRelationship] = [
        FriendRelationship(id: 11, nickname: "냠냠쩝쩝", isFavorite: true),
        FriendRelationship(id: 12, nickname: "또구몬", isFavorite: true),
        FriendRelationship(id: 13, nickname: "진키22", isFavorite: true),
        FriendRelationship(id: 14, nickname: "이초홍", isFavorite: false),
    ]
    
    lazy var mockMeeting = Meeting(
        id: 0,
        title: "2024 연말파티",
        description: "모임의 간단한 설명 예시",
        imageURL: nil,
        createdAt: .now,
        updatedAt: .now,
        schedule: nil,
        shareLink: nil,
        isFinished: false
    )
    
    lazy var mockPlace = Place(
        id: 0,
        userId: 0,
        meetingId: 0,
        name: "무드서울",
        address: "서울 용산구 한강대로 21길 18 1층",
        createdAt: .now,
        updatedAt: .now,
        likesCount: 1,
        pickedState: .unpicked,
        comments: mockComments,
        isSimulaneouslyPicked: true
    )
    
    lazy var mockComments: [Comment] = [
        Comment(placeId: 0, description: "여기 웨이팅 있어서 미리 예약하고 가는게 좋을 듯", writerId: 0, createdAt: .now, updatedAt: .now),
        Comment(placeId: 0, description: "야경 맛집임", writerId: 1, createdAt: .now, updatedAt: .now)
    ]
    
    private init() {
        let assembler = Assembler(
            [
                ServiceAssembly(),
                CoreAssembly(),
                ViewModelAssembly()
            ],
            container: Container()
        )
        self.resolver = assembler.resolver
    }
}
