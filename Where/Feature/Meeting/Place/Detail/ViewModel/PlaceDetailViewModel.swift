//
//  PlaceDetailViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/11/25.
//

import Foundation
import Combine
import Swinject

typealias CommentSheetType = PlaceDetailView.SheetType

@Observable
final class PlaceDetailViewModel {
    private(set) var isDeletionProcessing: Bool = false
    private(set) var isTogglingProcessing: Bool = false
    
    private let placeCore: PlaceCoreProtocol
    private let cancellableBag = CancellableBag()
    
    private var _comments = [UInt64: Comment]()
    private var placeID: UInt64?
    private var selectedComment: Comment?
    private var sheetTypeSubject = PassthroughSubject<CommentSheetType?, Never>()
    
    var comments: [Comment] {
        _comments.values.sorted { $0.createdAt < $1.createdAt }
    }
    
    init(resolver: Resolver) {
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
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
    
    func onApear(_ placeID: UInt64) {
        self.placeID = placeID
        placeCore.readSpecificPlace(id: placeID)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                //TODO: error handling
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                #if DEBUG
                    print("\(#file)-----\(#function)")
                    print("\(error.localizedDescription)")
                #endif
                }
            } receiveValue: { [weak self] in
                self?._comments = $0
            }
            .store(in: cancellableBag, key: "Comments")

    }
    
    var sheetPublisher: AnyPublisher<CommentSheetType?, Never> {
        sheetTypeSubject.eraseToAnyPublisher()
    }
}


// MARK: - CommentViewModelType

protocol CommentViewModelType {
    var comments: [Comment] { get }
    func createComment(_ description: String)
    func updateComment(_ descrition: String)
    func deleteComment()
    func setComment(_ comment: Comment)
}

extension PlaceDetailViewModel: CommentViewModelType {
    func createComment(_ description: String) {
        guard let placeID else { return }
        placeCore.createComment(placeID: placeID, description: description)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.sheetTypeSubject.send(.none)
                case .failure(let error): return
                }
                
            } receiveValue: { [weak self] in
                self?._comments[$0.id] = $0
            }
            .store(in: cancellableBag, key: #function)
    }
    
    func updateComment(_ descrition: String) {
        guard let comment = selectedComment else { return }
        placeCore.updateComment(comment: comment, description: descrition)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.sheetTypeSubject.send(.none)
                case .failure(let error):return
                }
            } receiveValue: { [weak self] newComment in
                self?._comments[comment.id] = newComment
            }
            .store(in: cancellableBag, key: #function)
        
    }
    
    func deleteComment() {
        guard let comment = selectedComment else { return }
        placeCore.deleteComment(comment: comment)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.sheetTypeSubject.send(.none)
                case .failure(let error): return
                }
            } receiveValue: { [weak self] in
                self?._comments.removeValue(forKey: $0)
            }
            .store(in: cancellableBag, key: #function)
    }
    
    func setComment(_ comment: Comment) {
        self.selectedComment = comment
    }
}


