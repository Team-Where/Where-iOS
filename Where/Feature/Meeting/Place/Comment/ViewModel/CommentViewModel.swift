//
//  CommentViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/11/25.
//

import Foundation
import Combine
import Swinject

protocol CommentCreatable {
    var isCreationProcessing: Bool { get }
    
    func createComment(placeID: UInt64, _ commentContent: String)
}

protocol CommentEditable {
    var isUpdatingProcessing: Bool { get }
    
    func editComment(_ commentContent: String)
}

protocol CommentDeletable {
    var isDeletionProcessing: Bool { get }
    
    func deleteComment(_ comment: Comment)
}

@MainActor
@Observable
final class CommentViewModel {
    private(set) var comments = [Comment]()
    private(set) var currentComment: Comment?
    private(set) var isCreationProcessing: Bool = false
    private(set) var isDeletionProcessing: Bool = false
    private(set) var isUpdatingProcessing: Bool = false
    
    private let placeCore: PlaceCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        placeCore.comments
            .sink { [weak self] dict in
                self?.comments = dict.values.sorted { $0.createdAt > $1.createdAt }
            }
            .store(in: cancellableBag, key: "Comments")
    }
}

// MARK: - Nested Types
extension CommentViewModel {
    /// 코멘트 화면에서 라우팅 가능한 시트의 종류
    enum SheetType: Identifiable {
        /// 코멘트 남기기(생성)
        case create
        /// 코멘트 내용 확인, 삭제
        case read(comment: Comment)
        /// 코멘트 수정
        case edit(comment: Comment)
        
        var id: String { String(describing: self) }
    }
}

// MARK: - Interfaces
extension CommentViewModel {
    func readComment(_ comment: Comment) {
        currentComment = comment
    }
}

// MARK: - CommentCreatable Conformation
extension CommentViewModel: @preconcurrency CommentCreatable {
    func createComment(placeID: UInt64, _ commentContent: String) {
        isCreationProcessing = true
        cancellableBag[#function] = placeCore.createComment(placeID: placeID, description: commentContent)
            .sink { [weak self] _ in
                self?.isCreationProcessing = false
            } receiveValue: { _ in }
    }
}

// MARK: - CommentEditable Conformation
extension CommentViewModel: @preconcurrency CommentEditable {
    func editComment(_ commentContent: String) {
        guard let currentComment else { return }
        
        isUpdatingProcessing = true
        cancellableBag[#function] = placeCore.updateComment(comment: currentComment, description: commentContent)
            .sink { [weak self] _ in
                self?.isUpdatingProcessing = false
            } receiveValue: { _ in }
    }
}

// MARK: - CommentDeletable Conformation
extension CommentViewModel: @preconcurrency CommentDeletable {
    func deleteComment(_ comment: Comment) {
        isDeletionProcessing = true
        cancellableBag[#function] = placeCore.deleteComment(comment: comment)
            .sink { [weak self] _ in
                self?.isDeletionProcessing = false
            } receiveValue: { _ in }
    }
}
