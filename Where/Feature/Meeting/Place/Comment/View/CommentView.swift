//
//  CommentView.swift
//  Where
//
//  Created by 이현호 on 1/20/25.
//

import SwiftUI
import Swinject


extension CommentView {
    typealias SheetType = PlaceDetailView.SheetType
}

struct CommentView: View {
    @Binding private var sheetType: SheetType?
    @Binding private var commentEditStep: EditStep?
    private let viewModel: CommentViewModelType
    
    init(sheetType: Binding<SheetType?>,
         commentEditStep: Binding<EditStep?>,
         viewModel: CommentViewModelType) {
        self._sheetType = sheetType
        self._commentEditStep = commentEditStep
        self.viewModel = viewModel
    }
    
    var body: some View {
        Section {
            commentList(viewModel.comments)
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
    }
    
    private var createCommentButton: some View {
        Button {
            sheetType = .comment(text: nil)
            commentEditStep = .create
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
            
            if comments.contains(where: { $0.isMyComment }) == false {
                createCommentButton
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
                viewModel.setComment(comment)
                sheetType = .comment(text: comment.description)
                commentEditStep = .myComment
            }
    }
}

enum EditStep {
    case myComment
    case create
    case modify
    
    var title: String {
        switch self {
        case .myComment: "코멘트"
        case .create: "코멘트 남기기"
        case .modify: "코멘트 수정"
        }
    }
}

extension PlaceDetailView {
    struct CommentSheet: View {
        @State private var text: String
        @State private var detent: PresentationDetent = .fraction(0)
        @Binding private var editStep: EditStep?
        @Binding private var sheetType: SheetType?
        @FocusState private var textFieldFocuseState: EditStep?
        
        private let viewModel: CommentViewModelType
        
        init(
            text: String?,
            editStep: Binding<EditStep?>,
            sheetType: Binding<SheetType?>,
            viewModel: CommentViewModelType
        ) {
            self._editStep = editStep
            self._text = .init(wrappedValue: text ?? "")
            self._sheetType = sheetType
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack {
                HStack {
                    Text(editStep?.title ?? "")
                        .whereFont(.subtitle18semibold)
                    Spacer()
                    
                    Button {
                        sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding(.vertical)
                switch editStep {
                case .myComment:
                    myComment
                default:
                    inputComment
                }
            }
            .padding(.horizontal)
        }

        var myComment: some View {
            VStack(alignment: .leading) {
                Text(text)
                    .padding(.bottom)
                    .whereFont(.body16regular)
                
                HStack(alignment: .center) {
                    Button {
                        viewModel.deleteComment()
                    } label: {
                        Group {
                            if viewModel.isDeletionProcessing {
                                ProgressView()
                            } else {
                                Text("삭제")
                            }
                        }
                        .whereFont(.body16regular)
                        .foregroundStyle(.where(.red500))
                        .frame(width: 169, height: 59)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: 0xF3F4F6))
                    )
                    
                    Button {
                        editStep = .modify
                    } label: {
                        Text("수정")
                            .whereFont(.body16regular)
                            .frame(width: 169, height: 59)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: 0xF3F4F6))
                    )
                }
                
            }
            .presentationDetents([.fraction(0.2)])
        }
        
        var inputComment: some View {
            VStack(alignment: .leading) {
                TextField(text: $text, axis: .vertical) {
                    Text("친구들이 볼 수 있도록 코멘트를 달아보세요. (최대 50자)")
                        .whereFont(.body16regular)
                }
                .lineLimit(2)
                .onChange(of: text) { _, newValue in
                    if newValue.count > 50 {
                        text = String(newValue.prefix(50))
                    }
                }
                .focused($textFieldFocuseState, equals: editStep)
                
                Spacer()
                HStack(alignment: .center) {
                    Button {
                        switch editStep {
                        case .modify:
                            editStep = .myComment
                        default:
                            sheetType = .none
                        }
                    } label: {
                        Text("취소")
                            .whereFont(.body16regular)
                            .foregroundStyle(.where(hex: 0x4B5563))
                            .frame(width: 169, height: 59)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: 0xF3F4F6))
                    )
                    Spacer()
                    Button {
                        switch editStep {
                        case .create:
                            viewModel.createComment(text)
                        case .modify:
                            viewModel.updateComment(text)
                        default: return
                        }
                    } label: {
                        Group {
                            if viewModel.isProcessing {
                                ProgressView()
                            } else {
                                Text("확인")
                            }
                        }
                        .whereFont(.body16regular)
                        .foregroundStyle(.where(hex: 0xFFFFFF))
                        .frame(width: 169, height: 59)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.accent)
                    )
                }
            }
            .presentationDetents(textFieldFocuseState == nil ? [.medium] : [.fraction(0.2)])
            .interactiveDismissDisabled()
        }
    }
}
