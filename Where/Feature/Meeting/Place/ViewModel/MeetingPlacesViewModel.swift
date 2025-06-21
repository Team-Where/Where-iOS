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
    private(set) var sortOption: PlaceSortOption = .all
    private var placesDict = [UInt64: Place]()
    
    private let placeCore: PlaceCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        placeCore.places
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            } receiveValue: { [weak self] places in
                self?.pickedPlaces = places.values
                    .filter { $0.pickedState == .picked }
                    .sorted { $0.likesCount > $1.likesCount }
                self?.placesDict = places
                
                guard let sortOption = self?.sortOption else { return }
                self?.changeSortOption(option: sortOption)
            }
            .store(in: cancellableBag, key: "Places")
    }
    
    private func sortByAll() {
        sortOption = .all
        places = placesDict.values.sorted {
            if $0.isSimulaneouslyShared != $1.isSimulaneouslyShared {
                return $0.isSimulaneouslyShared
            }
            
            guard $0.likesCount != $1.likesCount else {
                return $0.name < $1.name
            }
            return $0.likesCount > $1.likesCount
        }
    }
    
    private func sortByLikesDescending() {
        sortOption = .byLikesDescending
        let sortedByLikes = placesDict.values.sorted { $0.likesCount > $1.likesCount }
        
        guard sortedByLikes.count > 3 else {
            return places = sortedByLikes
        }
        
        var uniqueLikesCounts = [Int]()
        uniqueLikesCounts.reserveCapacity(3)
        
        for place in sortedByLikes {
            if place.likesCount != uniqueLikesCounts.last {
                uniqueLikesCounts.append(place.likesCount)
                
                if uniqueLikesCounts.count == 3 { break }
            }
        }
        
        let top3UniqueLikesSet = Set(uniqueLikesCounts)
        let top3Places = sortedByLikes.filter {
            top3UniqueLikesSet.contains($0.likesCount)
        }
        
        places = top3Places
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
    func changeSortOption(option: PlaceSortOption) {
        switch option {
        case .all: sortByAll()
        case .byLikesDescending: sortByLikesDescending()
        }
    }
}
