//
//  PlaceDetailViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/11/25.
//

import Foundation
import Combine
import Swinject

@MainActor
@Observable
final class PlaceDetailViewModel {
    private(set) var commentCount: Int = .zero
    private(set) var isDeletionProcessing: Bool = false
    private(set) var isTogglingProcessing: Bool = false
    
    private let placeCore: PlaceCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        placeCore.comments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dict in
                self?.commentCount = dict.count
            }
            .store(in: cancellableBag, key: "Comments")
    }
}

// MARK: - Interfaces
extension PlaceDetailViewModel {
    func deletePlace(id: UInt64) {
        isDeletionProcessing = true
        cancellableBag[#function] = placeCore.deletePlace(id: id)
            .sink { [weak self] _ in
                self?.isDeletionProcessing = false
            } receiveValue: { _ in }
    }
    
    func togglePick(id: UInt64) {
        isTogglingProcessing = true
        cancellableBag[#function] = placeCore.pickPlace(id: id)
            .sink { [weak self] _ in
                self?.isTogglingProcessing = false
            } receiveValue: { _ in }
    }
}
