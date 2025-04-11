//
//  CommentView.swift
//  Where
//
//  Created by 이현호 on 1/20/25.
//

import SwiftUI
import Swinject

fileprivate typealias SheetType = CommentViewModel.SheetType

struct CommentView: View {
    @ObservedObject private var viewModel: CommentViewModel
    @State private var comments: [String] = [] // 전체 코멘트 리스트
    @State private var myComment: String = "" // 내가 작성한 코멘트 (1개만 가능)
    @State private var isShowingCommentSheet: Bool = false // 코멘트 입력 Sheet 표시 여부
    @State private var selectedComment: String = "" // 선택한 코멘트 저장
    @State private var isCommentSheet: Bool = false // 코멘트 보기 Sheet 표시 여부
    @State private var isEditingCommentMode: Bool = false // 수정 모드 Sheet 표시 여부
    
    var totalCommentCount: Int {
        return comments.count + (myComment.isEmpty ? 0 : 1)
    }
    
    init(resolver: Resolver) {
        self.viewModel = resolver.resolve(CommentViewModel.self)!
    }

    var body: some View {
        Section {
            sectionContentArea()
        } header: {
            HStack(spacing: 4) {
                Text("코멘트")
                Text("\(totalCommentCount)")
                    .foregroundStyle(.where(hex: 0x4F46E5))
                Spacer()
            }
            .whereFont(.body16medium)
        }
        .padding(.horizontal, 20)
        .sheet(item: $viewModel.sheetType) { type in
            switch type {
            case .create:
                CommentCreationSheet(
                    sheetType: $viewModel.sheetType,
                    commentTextField: $viewModel.commentTextField
                )
            case .edit:
                Text("fdfsd")
            }
        }
    }
    
    @ViewBuilder private func sectionContentArea() -> some View {
        if comments.count == 0 {
            createCommentButton
        } else {
            
        }
    }
    
    private var createCommentButton: some View {
        Button {
            viewModel.sheetType = .create
        } label: {
            Text("코멘트 남기기")
                .whereFont(.body16medium)
                .foregroundStyle(.accent)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .strokeBorder(.where(hex: 0xDEE2E6))
                )
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Nested Types
extension CommentView {
    struct CommentCreationSheet: View {
        @Binding fileprivate var sheetType: SheetType?
        @Binding var commentTextField: String
        @FocusState private var commentFieldFocused: Bool
        
        private let headerTitle = "코멘트 남기기"
        
        var body: some View {
            VStack {
                HStack {
                    Text(headerTitle)
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(.where(.gray800))
                    
                    Spacer()
                    
                    Button {
                        sheetType = nil
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.where(.gray800))
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        PlaceDetailView(resolver: PreviewHelper.shared.resolver)
    }
}
