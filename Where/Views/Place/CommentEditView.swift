//
//  CommentEditView.swift
//  Where
//
//  Created by 이현호 on 2/2/25.
//

import SwiftUI

struct CommentEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var commentText: String
    var onUpdate: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack {
            // 상단 제목 + 닫기 버튼
            HStack {
                Text("코멘트 수정")
                    .whereFont(.subtitle18semibold)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }

            // 입력 부분
            VStack {
                TextField("", text: $commentText, axis: .vertical)
                    .whereFont(.body16regular)
                    .lineLimit(4)
                    .foregroundStyle(.black)
                    .onChange(of: commentText) {
                        if commentText.count > 50 {
                            commentText = String(commentText.prefix(50))
                        }
                    }

                Spacer()
            }
            .padding(.top, 12)

            // 하단 버튼
            HStack {
                Button {
                    onDelete()
                    dismiss()
                } label: {
                    RoundedRectangle(cornerSize: .init(width: 16, height: 16))
                        .overlay {
                            Text("삭제")
                                .whereFont(.body16medium)
                                .foregroundStyle(.red)
                        }
                }
                .frame(width: 169, height: 54)
                .foregroundStyle(Color(hex: 0xF3F4F6))
                .transition(.opacity)

                Button {
                    onUpdate()
                    dismiss()
                } label: {
                    RoundedRectangle(cornerSize: .init(width: 16, height: 16))
                        .overlay {
                            Text("수정")
                                .whereFont(.body16medium)
                                .foregroundStyle(Color(hex: 0x4F46E5))
                        }
                }
                .frame(width: 169, height: 54)
                .foregroundStyle(Color(hex: 0xF3F4F6))
                .transition(.opacity)
            }
        }
        .padding()
    }
}
