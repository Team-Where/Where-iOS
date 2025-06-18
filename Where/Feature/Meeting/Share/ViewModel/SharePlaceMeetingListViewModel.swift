//
//  SharePlaceMeetingListViewModel.swift
//  Where
//
//  Created by BOMBSGIE on 6/17/25.
//

import Foundation
import Swinject

@Observable
final class SharePlaceMeetingListViewModel {
    private(set) var meetings = [Meeting]()
    private(set) var selectedMeeting: Meeting?
    
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        meetingCore.meetings
            .map {
                $0.values.sorted { $0.createdAt > $1.createdAt }
            }
            .sink { [weak self] in
                self?.meetings = $0
            }
            .store(in: cancellableBag, key: #function)
    }
}

// MARK: - Interface

extension SharePlaceMeetingListViewModel {
    func select(meeting: Meeting) {
        selectedMeeting = meeting
    }
    
    func addPlace(_ placeName: String, _ placeURL: String) {
        // TODO: 장소 추가 기능 연결
    }
}

