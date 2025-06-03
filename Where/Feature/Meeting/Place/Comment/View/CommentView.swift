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
    @State private var sheetType: SheetType?
    
    private let viewModel: CommentViewModel
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
        .sheet(item: $sheetType) { type in
            switch type {
            case .create:
                CommentCreationSheet($sheetType, viewModel, placeID: place.id)
                
            case .read(let comment):
                CommentReadingSheet($sheetType, viewModel, comment)
                
            case .edit(let comment):
                CommentEditingSheet($sheetType, viewModel, comment)
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
            sheetType = .create
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
                viewModel.readComment(comment)
                sheetType = .read(comment: comment)
            }
    }
}

// MARK: - Nested Types
extension CommentView {
    struct CommentCreationSheet: View {
        @Binding fileprivate var sheetType: SheetType?
        @FocusState private var commentFieldFocused: Bool
        @State private var commentTextField = String()
        private let headerTitle = "코멘트 남기기"
        private let presentationCornerRadius: CGFloat = 8
        private let placeID: UInt64
        
        private let viewModel: CommentViewModel
        
        private var creationButtonDisabled: Bool {
            commentTextField.isEmpty || viewModel.isCreationProcessing
        }
        
        fileprivate init(
            _ sheetType: Binding<SheetType?>,
            _ viewModel: CommentViewModel,
            placeID: UInt64
        ) {
            self._sheetType = sheetType
            self.viewModel = viewModel
            self.placeID = placeID
        }
        
        var body: some View {
            VStack(spacing: 20) {
                HStack {
                    Text(headerTitle)
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(.where(.gray800))
                    
                    Spacer()
                    
                    Button {
                        onDismiss()
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
                        viewModel.createComment(placeID: placeID, commentTextField)
                    } label: {
                        if viewModel.isCreationProcessing {
                            ProgressView()
                        } else {
                            Text("확인")
                        }
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.accent)
                    )
                    .disabled(creationButtonDisabled)
                }
            }
            .onAppear {
                commentFieldFocused = true
            }
            .onChange(of: viewModel.isCreationProcessing, onCommentCreated)
            .padding()
            .presentationCornerRadius(presentationCornerRadius)
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled()
            .presentationDetents(commentFieldFocused ? [.fraction(0.2)] : [.medium])
        }
        
        private func onCommentCreated(_ : Bool, _ isDone: Bool) {
            guard isDone else { return }
            onDismiss()
        }
        
        private func onDismiss() {
            commentFieldFocused = false
            sheetType = nil
            commentTextField.removeAll()
        }
    }
    
    struct CommentReadingSheet: View {
        @Binding fileprivate var sheetType: SheetType?
        
        private let comment: Comment
        private let headerTitle = "코멘트"
        private let presentationCornerRadius: CGFloat = 8
        
        private let viewModel: CommentViewModel
        
        private var deletionButtonDisabled: Bool {
            viewModel.isDeletionProcessing
        }
        
        fileprivate init(
            _ sheetType: Binding<SheetType?>,
            _ viewModel: CommentViewModel,
            _ comment: Comment
        ) {
            self._sheetType = sheetType
            self.viewModel = viewModel
            self.comment = comment
        }
        
        var body: some View {
            VStack(spacing: 20) {
                HStack {
                    Text(headerTitle)
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(.where(.gray800))
                    
                    Spacer()
                    
                    Button {
                        onDismiss()
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
                        viewModel.deleteComment(comment)
                    } label: {
                        if viewModel.isDeletionProcessing {
                            ProgressView()
                        } else {
                            Text("삭제")
                        }
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.where(.red500))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.where(.gray100))
                    )
                    .disabled(deletionButtonDisabled)
                    
                    Button {
                        sheetType = .edit(comment: comment)
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
            .onChange(of: viewModel.isDeletionProcessing, onCommentDeleted)
            .padding()
            .presentationCornerRadius(presentationCornerRadius)
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled()
            .presentationDetents([.fraction(0.3)])
        }
        
        private func onCommentDeleted(_ : Bool, _ isDone: Bool) {
            guard isDone else { return }
            onDismiss()
        }
        
        private func onDismiss() {
            sheetType = nil
        }
    }
    
    struct CommentEditingSheet: View {
        @Binding fileprivate var sheetType: SheetType?
        @FocusState private var commentFieldFocused: Bool
        @State private var commentTextField = String()
        private let comment: Comment
        private let headerTitle = "코멘트 수정"
        private let presentationCornerRadius: CGFloat = 8
        
        private let viewModel: CommentEditable
        
        private var updatingButtonDisabled: Bool {
            commentTextField.isEmpty || viewModel.isUpdatingProcessing
        }
        
        fileprivate init(
            _ sheetType: Binding<SheetType?>,
            _ viewModel: CommentEditable,
            _ comment: Comment
        ) {
            self._sheetType = sheetType
            self.viewModel = viewModel
            self.comment = comment
        }
        
        var body: some View {
            VStack(spacing: 20) {
                HStack {
                    Text(headerTitle)
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(.where(.gray800))
                    
                    Spacer()
                    
                    Button {
                        onDismiss()
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
                        viewModel.editComment(commentTextField)
                    } label: {
                        if viewModel.isUpdatingProcessing {
                           ProgressView()
                        } else {
                            Text("확인")
                        }
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.accent)
                    )
                    .disabled(updatingButtonDisabled)
                }
            }
            .padding()
            .onAppear {
                commentTextField = comment.description
                commentFieldFocused = true
            }
            .onChange(of: viewModel.isUpdatingProcessing, onCommentUpdated)
            .presentationCornerRadius(presentationCornerRadius)
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled()
            .presentationDetents(commentFieldFocused ? [.fraction(0.2)] : [.medium])
        }
        
        private func onCommentUpdated(_ : Bool, _ isDone: Bool) {
            guard isDone else { return }
            onDismiss()
        }
        
        private func onDismiss() {
            commentFieldFocused = false
            sheetType = nil
            commentTextField.removeAll()
        }
    }
}
