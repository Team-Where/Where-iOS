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
    
    private let place: Place
    
    init(
        place: Place,
        resolver: Resolver
    ) {
        self.place = place
        self.viewModel = resolver.resolve(CommentViewModel.self)!
    }
    
    var body: some View {
        Section {
            sectionContentArea()
        } header: {
            HStack(spacing: 4) {
                Text("코멘트")
                Text("\(viewModel.comments.count)")
                    .foregroundStyle(.where(hex: 0x4F46E5))
                Spacer()
            }
            .whereFont(.body16medium)
        }
        .padding(.horizontal, 20)
        .sheet(item: $viewModel.sheetType) { type in
            switch type {
            case .create:
                CommentCreationSheet($viewModel.sheetType, commentTextField: $viewModel.commentTextField) {
                    viewModel.createComment(placeID: place.id)
                }
                
            case .read(let comment):
                CommentReadingSheet($viewModel.sheetType, comment) { comment in
                    viewModel.deleteComment(comment)
                } onEdit: {
                    viewModel.presentEditingSheet()
                }
                
            case .edit:
                CommentEditingSheet($viewModel.sheetType, commentTextField: $viewModel.commentTextField) {
                    viewModel.editComment()
                }
            }
        }
    }
    
    @ViewBuilder private func sectionContentArea() -> some View {
        if viewModel.comments.count == 0 {
            createCommentButton
        } else {
            commentList(viewModel.comments)
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
    
    @ViewBuilder private func commentList(_ comments: [Comment]) -> some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(comments, id: \.self) { comment in
                commentCell(comment)
            }
        }
        .padding(.vertical, 20)
    }
    
    @ViewBuilder private func commentCell(_ comment: Comment) -> some View {
        Text(comment.description)
            .whereFont(.body14regular)
            .foregroundStyle(.where(.gray800))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                    .strokeBorder(comment.isMyComment ? .accent : .where(.gray800))
            )
            .onTapGesture {
                guard comment.isMyComment else { return }
                viewModel.presentReadingSheet(comment: comment)
            }
    }
}

// MARK: - Nested Types
extension CommentView {
    struct CommentCreationSheet: View {
        @Binding fileprivate var sheetType: SheetType?
        @Binding var commentTextField: String
        @FocusState private var commentFieldFocused: Bool
        let onSubmit: () -> Void
        
        private let headerTitle = "코멘트 남기기"
        private let presentationCornerRadius: CGFloat = 8
        
        fileprivate init(
            _ sheetType: Binding<SheetType?>,
            commentTextField: Binding<String>,
            onSubmit: @escaping () -> Void
        ) {
            self._sheetType = sheetType
            self._commentTextField = commentTextField
            self.onSubmit = onSubmit
        }
        
        var body: some View {
            VStack(spacing: 20) {
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
                .padding(.top)
                
                TextField(text: $commentTextField) {
                    Text("친구들이 볼 수 있도록 코멘트를 달아보세요. (최대 50자)")
                        .whereFont(.body16regular)
                }
                .focused($commentFieldFocused)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        commentFieldFocused = false
                        commentTextField.removeAll()
                        sheetType = .none
                    } label: {
                        Text("취소")
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color(hex: 0x4B5563))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: 0xF3F4F6))
                    )
                    
                    Button {
                        commentFieldFocused = false
                        onSubmit()
                        sheetType = .none
                    } label: {
                        Text("확인")
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.accent)
                    )
                    .disabled(commentTextField.isEmpty)
                }
            }
            .onAppear {
                commentFieldFocused = true
            }
            .padding()
            .presentationCornerRadius(presentationCornerRadius)
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled()
            .presentationDetents(commentFieldFocused ? [.fraction(0.2)] : [.medium])
        }
    }
    
    struct CommentReadingSheet: View {
        @Binding fileprivate var sheetType: SheetType?
        
        private let comment: Comment
        private let onDelete: (Comment) -> Void
        private let onEdit: () -> Void
        private let headerTitle = "코멘트"
        private let presentationCornerRadius: CGFloat = 8
        
        fileprivate init(
            _ sheetType: Binding<SheetType?>,
            _ comment: Comment,
            onDelete: @escaping (Comment) -> Void,
            onEdit: @escaping () -> Void
        ) {
            self._sheetType = sheetType
            self.comment = comment
            self.onDelete = onDelete
            self.onEdit = onEdit
        }
        
        var body: some View {
            VStack(spacing: 20) {
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
                .padding(.top)
                
                Text(comment.description)
                    .whereFont(.body16regular)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        onDelete(comment)
                    } label: {
                        Text("삭제")
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.where(.red500))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.where(.gray100))
                    )
                    
                    Button {
                        onEdit()
                    } label: {
                        Text("수정")
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.accent)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.where(.gray100))
                    )
                }
            }
            .padding()
            .presentationCornerRadius(presentationCornerRadius)
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled()
            .presentationDetents([.fraction(0.3)])
        }
    }
    
    struct CommentEditingSheet: View {
        @Binding fileprivate var sheetType: SheetType?
        @Binding var commentTextField: String
        @FocusState private var commentFieldFocused: Bool
        private let onSubmit: () -> Void
        private let headerTitle = "코멘트 수정"
        private let presentationCornerRadius: CGFloat = 8
        
        fileprivate init(
            _ sheetType: Binding<SheetType?>,
            commentTextField: Binding<String>,
            onSubmit: @escaping () -> Void
        ) {
            self._sheetType = sheetType
            self._commentTextField = commentTextField
            self.onSubmit = onSubmit
        }
        
        var body: some View {
            VStack(spacing: 20) {
                HStack {
                    Text(headerTitle)
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(.where(.gray800))
                    
                    Spacer()
                    
                    Button {
                        sheetType = nil
                        commentTextField.removeAll()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.where(.gray800))
                    }
                }
                .padding(.top)
                
                TextField(text: $commentTextField) {
                    Text("친구들이 볼 수 있도록 코멘트를 달아보세요. (최대 50자)")
                        .whereFont(.body16regular)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        onDismiss()
                    } label: {
                        Text("취소")
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color(hex: 0x4B5563))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: 0xF3F4F6))
                    )
                    
                    Button {
                        onSubmit()
                    } label: {
                        Text("확인")
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.accent)
                    )
                    .disabled(commentTextField.isEmpty)
                }
            }
            .padding()
            .presentationCornerRadius(presentationCornerRadius)
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled()
            .presentationDetents(commentFieldFocused ? [.fraction(0.2)] : [.medium])
        }
        
        private func onDismiss() {
            commentFieldFocused = false
            commentTextField.removeAll()
            sheetType = .none
        }
    }
}
