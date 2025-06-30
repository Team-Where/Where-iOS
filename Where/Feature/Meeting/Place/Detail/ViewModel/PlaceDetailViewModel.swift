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

final class PlaceDetailViewModel: ObservableObject {
    private(set) var isLikeTogglingProcessing: Bool = false
    private(set) var isDeletionProcessing: Bool = false
    private(set) var isTogglingProcessing: Bool = false
    private(set) var isProcessing: Bool = false
    
    var comments: [Comment] {
        commentsDict.values.sorted {
            guard $0.isMyComment == $0.isMyComment else {
                return $0.createdAt > $1.createdAt
            }
            return $0.isMyComment
        }
    }
    
    private let placeCore: PlaceCoreProtocol
    private let cancellableBag = CancellableBag()
    
    private var commentsDict = [UInt64: Comment]()
    private var placeID: UInt64?
    private var selectedComment: Comment?
    private var sheetTypeSubject = PassthroughSubject<CommentSheetType?, Never>()
    
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
    
    func readComments(_ placeID: UInt64) {
        self.placeID = placeID
        placeCore.readSpecificPlace(id: placeID)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                #if DEBUG
                print("\(#file)-----\(#function)")
                print("\(error.localizedDescription)")
                #endif
            } receiveValue: { [weak self] in
                self?.commentsDict = $0
            }
            .store(in: cancellableBag, key: "Comments")
    }
    
    func tapPlaceLike(id: UInt64) {
        isLikeTogglingProcessing = true
        placeCore.togglePlaceLike(id: id)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLikeTogglingProcessing = false
                
                guard case .failure(let error) = completion else { return }
                #if DEBUG
                print("\(#file)-----\(#function)")
                print("\(error.localizedDescription)")
                #endif
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
    }
    
    var sheetPublisher: AnyPublisher<CommentSheetType?, Never> {
        sheetTypeSubject.eraseToAnyPublisher()
    }
}


// MARK: - CommentViewModelType

protocol CommentViewModelType {
    var comments: [Comment] { get }
    var isProcessing: Bool { get }
    var isDeletionProcessing: Bool { get }
    
    func createComment(_ description: String)
    func updateComment(_ descrition: String)
    func deleteComment()
    func setComment(_ comment: Comment)
}

extension PlaceDetailViewModel: CommentViewModelType {
    func createComment(_ description: String) {
        guard let placeID else { return }
        isProcessing = true
        placeCore.createComment(placeID: placeID, description: description)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isProcessing = false
                switch completion {
                case .finished:
                    self?.sheetTypeSubject.send(.none)
                case .failure(let error): return
                }
                
            } receiveValue: { [weak self] in
                self?.commentsDict[$0.id] = $0
            }
            .store(in: cancellableBag, key: #function)
    }
    
    func updateComment(_ descrition: String) {
        guard let comment = selectedComment else { return }
        isProcessing = true
        placeCore.updateComment(comment: comment, description: descrition)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isProcessing = false
                switch completion {
                case .finished:
                    self?.sheetTypeSubject.send(.none)
                case .failure(let error):return
                }
            } receiveValue: { [weak self] newComment in
                self?.commentsDict[comment.id] = newComment
            }
            .store(in: cancellableBag, key: #function)
        
    }
    
    func deleteComment() {
        guard let comment = selectedComment else { return }
        isDeletionProcessing = true
        placeCore.deleteComment(comment: comment)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isDeletionProcessing = false
                switch completion {
                case .finished:
                    self?.sheetTypeSubject.send(.none)
                case .failure(let error): return
                }
            } receiveValue: { [weak self] in
                self?.commentsDict.removeValue(forKey: $0)
            }
            .store(in: cancellableBag, key: #function)
    }
    
    func setComment(_ comment: Comment) {
        self.selectedComment = comment
    }
}
