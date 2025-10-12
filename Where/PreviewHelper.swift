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
