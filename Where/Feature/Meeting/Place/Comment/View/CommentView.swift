//
//  CommentView.swift
//  Where
//
//  Created by 이현호 on 1/20/25.
//

import SwiftUI

struct CommentView: View {
    @State private var comments: [String] = [] // 전체 코멘트 리스트
    @State private var myComment: String = "" // 내가 작성한 코멘트 (1개만 가능)
    @State private var isShowingCommentSheet: Bool = false // 코멘트 입력 Sheet 표시 여부
    @State private var selectedComment: String = "" // 선택한 코멘트 저장
    @State private var isCommentSheet: Bool = false // 코멘트 보기 Sheet 표시 여부
    @State private var isEditingCommentMode: Bool = false // 수정 모드 Sheet 표시 여부
    
    var totalCommentCount: Int {
        return comments.count + (myComment.isEmpty ? 0 : 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text("코멘트")
                Text("\(totalCommentCount)") // 전체 코멘트 개수
                    .foregroundStyle(Color(hex: 0x4F46E5))
                Spacer()
            }
            .whereFont(.body16medium)

            // 내 코멘트 작성 (1개만 가능)
            if myComment.isEmpty {
                Button {
                    isShowingCommentSheet = true
                } label: {
                    Text("코멘트 남기기")
                        .whereFont(.body16medium)
                        .foregroundStyle(Color(hex: 0x4F46E5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 43)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: 0xDEE2E6), lineWidth: 1)
                        )
                }
                .padding(.top, 16)
            } else {
                HStack {
                    Text(myComment)
                        .whereFont(.body14regular)
                        .foregroundStyle(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: 0x4F46E5), lineWidth: 1)
                        )
                        .onTapGesture {
                            selectedComment = myComment
                            isCommentSheet = true
                        }
                    Spacer()
                }
                .padding(.top, 16)
            }

            // 다른 사람들의 코멘트 표시
            VStack {
                ForEach(comments, id: \.self) { comment in
                    if comment != myComment { // 내 코멘트는 제외하고 표시
                        HStack {
                            Text(comment)
                                .whereFont(.body14regular)
                                .foregroundStyle(.gray)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: 0xE3E4E9), lineWidth: 1)
                                )
                            Spacer()
                        }
                    }
                }
            }
            .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal, 20)

        // 입력 Sheet (내 코멘트 추가)
        .sheet(isPresented: $isShowingCommentSheet) {
            CommentInputView(commentText: $myComment) {
                isShowingCommentSheet = false
            }
            .presentationDetents([.fraction(0.5)])
            .presentationCornerRadius(16)
        }
        
        // 입력된 코멘트 보기 Sheet
        .sheet(isPresented: $isCommentSheet) {
            CommentSheetView(
                selectedComment: $selectedComment,
                onEdit: {
                    isCommentSheet = false
                    isEditingCommentMode = true // 코멘트 수정
                },
                onDelete: {
                    myComment = "" // 내 코멘트 삭제
                    isCommentSheet = false
                }
            )
            .presentationDetents([.fraction(0.28)])
            .presentationCornerRadius(16)
        }

        // 내 코멘트 수정 Sheet
        .sheet(isPresented: $isEditingCommentMode) {
            CommentEditView(commentText: $myComment, onUpdate: {
                isEditingCommentMode = false
            })
            .presentationDetents([.fraction(0.5)])
            .presentationCornerRadius(16)
        }
    }
}
