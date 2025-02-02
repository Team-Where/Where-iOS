//
//  CommentView.swift
//  Where
//
//  Created by 이현호 on 1/20/25.
//

import SwiftUI

struct CommentView: View {
    @State private var comments: [String] = [] // 코멘트 저장
    @State private var commentText: String = ""
    @State private var isShowingCommentSheet: Bool = false // 코멘트 시트 표시
    @State private var selectedComment: String = "" // 선택한 코멘트 저장
    @State private var editedComment: String = "" // 수정할 코멘트 저장
    @State private var isEditingComment: Bool = false // 수정/삭제 Sheet 표시 여부
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text("코멘트")
                
                Text("\(comments.count)")
                
                Spacer()
            }
            .whereFont(.body16medium)
            
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
            
            // 생성된 코멘트
            VStack {
                if comments.isEmpty {
                    // 코멘트 비었을 때
                } else {
                    ForEach(comments, id: \.self) { comment in
                        HStack {
                            Text(comment)
                                .whereFont(.body14regular)
                                .foregroundStyle(.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: 0x4F46E5), lineWidth: 1)
                                )
                                .onTapGesture {
                                    selectedComment = comment // 수정할 코멘트 저장
                                    editedComment = comment // 기존 값 복사
                                    isEditingComment = true // 수정/삭제 Sheet 열기
                                }
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        // 입력 Sheet
        .sheet(isPresented: $isShowingCommentSheet, onDismiss: {
            commentText = "" // Sheet가 닫힐 때 초기화
        }) {
            CommentInputView(commentText: $commentText) {
                if !commentText.isEmpty {
                    comments.append(commentText)
                    commentText = ""
                }
                isShowingCommentSheet = false
            }
            .presentationDetents([.fraction(0.5)])
            .presentationCornerRadius(16)
        }
        // 수정 Sheet
        .sheet(isPresented: $isEditingComment) {
            CommentEditView(commentText: $editedComment, onUpdate: {
                if let index = comments.firstIndex(of: selectedComment) {
                    comments[index] = editedComment // 코멘트 수정
                }
                isEditingComment = false
            }, onDelete: {
                comments.removeAll { $0 == selectedComment } // 코멘트 삭제
                isEditingComment = false
            })
            .presentationDetents([.fraction(0.25)])
            .presentationCornerRadius(16)
        }
    }
}


#Preview {
    CommentView()
}
