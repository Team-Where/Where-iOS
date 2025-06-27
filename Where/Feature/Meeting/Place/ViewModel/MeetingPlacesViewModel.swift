//
//  MeetingPlacesViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/10/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class MeetingPlacesViewModel {
    private(set) var pickedPlaces = [Place]()
    private(set) var places = [Place]()
    private(set) var placesSortedByLikes = [[Place]]()
    private(set) var sortOption: PlaceSortOption = .all
    private var placesDict = [UInt64: Place]()
    
    private let placeCore: PlaceCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        
    }
    
    private func sortByAll(_ places: [UInt64: Place]) -> [Place] {
        places.values.sorted {
            if $0.isSimulaneouslyShared != $1.isSimulaneouslyShared {
                return $0.isSimulaneouslyShared
            }
            
            guard $0.likesCount != $1.likesCount else {
                return $0.name < $1.name
            }
            return $0.likesCount > $1.likesCount
        }
    }
    
    private func sortByLikesDescending(_ places: [UInt64: Place]) -> [[Place]] {
        guard places.isEmpty == false else { return [] }
        
        let sortedPlaces = places.values.sorted {
            guard $0.likesCount == $1.likesCount else {
                return $0.likesCount > $1.likesCount
            }
            
            guard $0.isSimulaneouslyShared == $1.isSimulaneouslyShared else {
                return $0.isSimulaneouslyShared
            }
            
            return $0.name < $1.name
        }
        
        var result: [[Place]] = []
        var currentGroup: [Place] = [sortedPlaces[0]]
        var previousLikes = sortedPlaces[0].likesCount
        
        for place in sortedPlaces.dropFirst() {
            guard result.count < 3 else { break }
            
            if place.likesCount == previousLikes {
                currentGroup.append(place)
            } else {
                result.append(currentGroup)
                currentGroup = [place]
                previousLikes = place.likesCount
            }
        }
        
        if currentGroup.isEmpty == false && result.count < 3 {
            result.append(currentGroup)
        }
        
        return result
    }
}

// MARK: - Nested Types
extension MeetingPlacesViewModel {
    /// 장소 목록 정렬 조건
    enum PlaceSortOption: CaseIterable {
        /// 전체보기
        case all
        /// Likes 수 내림차순, 3위까지
        case byLikesDescending
        
        var title: String {
            switch self {
            case .all: "전체보기"
            case .byLikesDescending: "BEST 순위"
            }
        }
    }
    
    /// 장소 목록 화면에서 라우팅 가능한 시트의 종류
    enum SheetType: Identifiable {
        case sharePlace
        
        var id: Int { self.hashValue }
    }
}

// MARK: - Interfaces
extension MeetingPlacesViewModel {
    func onAppear(meetingID: UInt64) {
        placeCore.places
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print("Error occured while fetching places: \(error)")
                    #endif
                }
            } receiveValue: { [weak self] places in
                let filteredPlaces = places.filter { $0.value.meetingId == meetingID }
                self?.pickedPlaces = filteredPlaces.values
                    .filter { $0.pickedState == .picked }
                    .sorted { $0.likesCount > $1.likesCount }
                
                self?.places = self?.sortByAll(filteredPlaces) ?? []
                self?.placesSortedByLikes = self?.sortByLikesDescending(filteredPlaces) ?? []
            }
            .store(in: cancellableBag, key: "Places")
    }
    
    func changeSortOption(option: PlaceSortOption) {
        sortOption = option
    }
}
