//
//  MeetingPlacesViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/10/25.
//

import Foundation
import Combine
import Swinject

final class MeetingPlacesViewModel: ObservableObject {
    @Published var sortOption: PlaceSortOption = .all
    @Published var isPickTipPresented: Bool = false
    @Published var isShareTipPresented: Bool = false
    @Published var pickedPlaces = [Place]()
    @Published var places = [Place]()
    
    private let placeCore: PlaceCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        placeCore.places
            .combineLatest($sortOption.setFailureType(to: PlaceCoreError.self))
            .map { (dict, option) -> [Place] in
                switch option {
                case .all:
                    return dict.values.sorted {
                        if $0.isSimulaneouslyShared != $1.isSimulaneouslyShared {
                            return $0.isSimulaneouslyShared
                        }
                        
                        guard $0.likesCount != $1.likesCount else {
                            return $0.name < $1.name
                        }
                        return $0.likesCount > $1.likesCount
                    }
                    
                case .byLikesDescending:
                    let sortedByLikes = dict.values.sorted { $0.likesCount > $1.likesCount }
                    
                    guard sortedByLikes.count > 3 else {
                        return sortedByLikes
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
                    
                    return top3Places
                }
            }
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
                self?.places = places
            }
            .store(in: &cancellables)
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
}

// MARK: - Interfaces
extension MeetingPlacesViewModel {
    func onAppear() {
        isShareTipPresented = places.isEmpty
    }
    
    func changeSortOption(option: PlaceSortOption) {
        sortOption = option
    }
}
