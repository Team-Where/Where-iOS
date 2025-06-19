//
//  SharePlaceMeetingListViewModel.swift
//  Where
//
//  Created by BOMBSGIE on 6/17/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class SharePlaceMeetingListViewModel {
    private(set) var meetings = [Meeting]()
    private(set) var selectedMeeting: Meeting?
    
    private let meetingCore: MeetingCoreProtocol
    private let placeCore: PlaceCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
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
    
    func addPlace(_ sharedPlace: SharedPlaceDataSource) {
        // TODO: 장소 추가 기능 연결
        guard let meetingID = selectedMeeting?.id else { return }
        
        Just(sharedPlace)
            .flatMap { [placeCore] sharedPlace -> AnyPublisher<Void, PlaceCoreError> in
                let name = sharedPlace.name
                
                switch sharedPlace.sourceApp {
                case .kakaomap:
                    guard let url = sharedPlace.urlString else {
                        return Fail(outputType: Void.self, failure: PlaceCoreError.userIDNotSet).eraseToAnyPublisher()
                    }
                    return placeCore.createPlaceByKakaomap(meetingID: meetingID, name: name, url: url)
                case .navermap:
                    guard let address = sharedPlace.address else {
                        return Fail(outputType: Void.self, failure: PlaceCoreError.userIDNotSet).eraseToAnyPublisher()
                    }
                    return placeCore.createPlaceByNavermap(meetingID: meetingID, name: name, address: address)
                }
            }
            .sink { [weak self] completion in
                // TODO: 에러 처리
                // 대충 실패하면 플로터 띄워서 알려주기..이런거?
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
    }
}

