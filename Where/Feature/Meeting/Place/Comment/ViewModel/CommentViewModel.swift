//
//  CommentViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/11/25.
//

import Foundation
import Combine

final class CommentViewModel: ObservableObject {
    @Published var sheetType: SheetType?
    @Published var comments = [Comment]()
    @Published var myComment: Comment?
    @Published var commentTextField = String()
}

// MARK: - Nested Types
extension CommentViewModel {
    /// 코멘트 화면에서 라우팅 가능한 시트의 종류
    enum SheetType: Identifiable {
        /// 코멘트 남기기(생성)
        case create
        /// 코멘트 내용 확인, 삭제, 수정
        case edit
        
        var id: String { String(describing: self) }
    }
}

// MARK: - Interfaces
extension CommentViewModel {
    func presentCreationSheet() {
        sheetType = .create
    }
}
