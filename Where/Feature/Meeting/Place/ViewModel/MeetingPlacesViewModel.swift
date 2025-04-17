//
//  MeetingPlacesViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/10/25.
//

import Foundation
import Combine

final class MeetingPlacesViewModel: ObservableObject {
    @Published var sortOption: PlaceSortOption = .all
    @Published var isPickTipPresented: Bool = false
    @Published var isShareTipPresented: Bool = false
    @Published var pickedPlaces = [Place]()
    @Published var places = [Place]()
    
    private let placeCore: PlaceCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(placeCore: PlaceCoreProtocol) {
        self.placeCore = placeCore
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
            } receiveValue: { [weak self] dict in
                self?.places = dict.values.sorted {
                    // 동시 선택된 장소라면 최우선 정렬
                    if $0.isSimulaneouslyPicked != $1.isSimulaneouslyPicked {
                        return $0.isSimulaneouslyPicked
                    }
                    
                    // 좋아요, 코멘트 수로 비교하여 내림차순으로 정렬
                    let count1 = $0.likesCount + $0.comments.count
                    let count2 = $1.likesCount + $1.comments.count
                    guard count1 != count2 else {
                        // 수가 같으면 장소명 사전순으로 정렬
                        return $0.name < $1.name
                    }
                    return count1 > count2
                }
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
