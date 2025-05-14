//
//  CommentViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/11/25.
//

import Foundation
import Combine
import Swinject

@MainActor
final class CommentViewModel: ObservableObject {
    @Published var sheetType: SheetType?
    @Published var comments = [Comment]()
    @Published var currentComment: Comment?
    @Published var commentTextField = String()
    @Published private(set) var isCreationProcessing: Bool = false
    @Published private(set) var isDeletionProcessing: Bool = false
    @Published private(set) var isUpdatingProcessing: Bool = false
    
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
        case edit
        
        var id: String { String(describing: self) }
    }
}

// MARK: - Interfaces
extension CommentViewModel {
    func presentCreationSheet() {
        sheetType = .create
    }
    
    func dismissSheet() {
        sheetType = nil
    }
    
    func createComment(placeID: UInt64) {
        isCreationProcessing = true
        cancellableBag[#function] = placeCore.createComment(placeID: placeID, description: commentTextField)
            .sink { [weak self] _ in
                self?.isCreationProcessing = false
            } receiveValue: { _ in }
    }
    
    func presentReadingSheet(comment: Comment) {
        currentComment = comment
        sheetType = .read(comment: comment)
    }
    
    func deleteComment(_ comment: Comment) {
        isDeletionProcessing = true
        cancellableBag[#function] = placeCore.deleteComment(comment: comment)
            .sink { [weak self] _ in
                self?.isDeletionProcessing = false
            } receiveValue: { _ in }
    }
    
    func presentEditingSheet() {
        guard let currentComment else { return }
        commentTextField = currentComment.description
        sheetType = .edit
    }
    
    func editComment() {
        guard let currentComment else { return }
        
        isUpdatingProcessing = true
        cancellableBag[#function] = placeCore.updateComment(comment: currentComment, description: commentTextField)
            .sink { [weak self] _ in
                self?.isUpdatingProcessing = false
            } receiveValue: { _ in }
    }
}
