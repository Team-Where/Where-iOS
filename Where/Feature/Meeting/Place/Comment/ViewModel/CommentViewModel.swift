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
    private var currentPlace: Place?
    
    private let placeCore: PlaceCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.placeCore = resolver.resolve(PlaceCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        placeCore.currentPlace
            .combineLatest(placeCore.currentPlaceComments)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            } receiveValue: { [weak self] (place, comments) in
                self?.currentPlace = place
                self?.comments = comments.sorted {
                    let date1 = $0.updatedAt > $0.createdAt ? $0.updatedAt : $0.createdAt
                    let date2 = $1.updatedAt > $1.createdAt ? $1.updatedAt : $1.createdAt
                    return date1 < date2
                }
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
    
    func createComment() {
        guard let currentPlace else { return }
        placeCore.createComment(placeID: currentPlace.id, description: commentTextField)
    }
    
    func presentReadingSheet(comment: Comment) {
        currentComment = comment
        sheetType = .read(comment: comment)
    }
    
    func deleteComment(_ comment: Comment) {
        placeCore.deleteComment(id: comment.placeId)
    }
    
    func presentEditingSheet() {
        guard let currentComment else { return }
        commentTextField = currentComment.description
        sheetType = .edit
    }
    
    func editComment() {
        guard let currentComment else { return }
        placeCore.updateComment(id: currentComment.placeId, description: commentTextField)
    }
    
    func isMyComment(_ comment: Comment) -> Bool {
        placeCore.isMyComment(comment: comment)
    }
}
