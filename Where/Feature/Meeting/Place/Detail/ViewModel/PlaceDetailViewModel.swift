//
//  PlaceDetailViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/11/25.
//

import Foundation
import Combine

final class PlaceDetailViewModel: ObservableObject {
    @Published var isDeletionSheetPresented = false
    @Published var isTipPresented = false
    @Published var place: Place?
    var isPicked: Bool { place?.pickedState == .picked }
    
    private let placeCore: PlaceCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(placeCore: PlaceCoreProtocol) {
        self.placeCore = placeCore
        subscribe()
    }
    
    private func subscribe() {
        placeCore.currentPlaceSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            } receiveValue: { [weak self] place in
                self?.place = place
            }
            .store(in: &cancellables)
    }
}

// MARK: - Interfaces
extension PlaceDetailViewModel {
    func onAppear(_ place: Place) {
        placeCore.readCurrentPlace(id: place.id)
        isTipPresented = place.pickedState == .unpicked
        
        guard isTipPresented == true else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isTipPresented = false
        }
    }
    
    func presentDeletionSheet() {
        isDeletionSheetPresented = true
    }
    
    func deletePlace() {
        guard let placeID = place?.id else { return }
        placeCore.deletePlace(id: placeID)
    }
    
    func togglePick() {
        guard let placeID = place?.id else { return }
        placeCore.pickPlace(id: placeID)
    }
}
