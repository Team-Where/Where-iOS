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
                self?.comments = dict.values.sorted { $0.createdAt > $1.createdAt }
            }
            .store(in: &cancellables)
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
    
    func createComment(placeID: UInt64) {
        placeCore.createComment(placeID: placeID, description: commentTextField)
    }
    
    func presentReadingSheet(comment: Comment) {
        currentComment = comment
        sheetType = .read(comment: comment)
    }
    
    func deleteComment(_ comment: Comment) {
        placeCore.deleteComment(comment: comment)
    }
    
    func presentEditingSheet() {
        guard let currentComment else { return }
        commentTextField = currentComment.description
        sheetType = .edit
    }
    
    func editComment() {
        guard let currentComment else { return }
        placeCore.updateComment(comment: currentComment, description: commentTextField)
    }
    
    func isMyComment(_ comment: Comment) -> Bool {
        placeCore.isMyComment(comment: comment)
    }
}
