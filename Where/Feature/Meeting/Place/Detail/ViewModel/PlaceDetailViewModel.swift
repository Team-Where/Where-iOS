//
//  PlaceDetailViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/11/25.
//

import Foundation
import Combine
import Swinject

final class PlaceDetailViewModel: ObservableObject {
    @Published var isDeletionSheetPresented = false
    @Published var isTipPresented = false
    @Published var commentCount: Int = .zero
    
    private let placeCore: PlaceCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        placeCore.comments
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] dict in
                self?.commentCount = dict.count
            }
            .store(in: &cancellables)
    }
}

// MARK: - Interfaces
extension PlaceDetailViewModel {
    func onAppear(_ place: Place) {
        isTipPresented = place.pickedState == .unpicked
        
        guard isTipPresented == true else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isTipPresented = false
        }
    }
    
    func presentDeletionSheet() {
        isDeletionSheetPresented = true
    }
    
    func deletePlace(id: UInt64) {
        placeCore.deletePlace(id: id)
    }
    
    func togglePick(id: UInt64) {
        placeCore.pickPlace(id: id)
    }
}
