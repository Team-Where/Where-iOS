//
//  CommentEditView.swift
//  Where
//
//  Created by 이현호 on 2/2/25.
//

import SwiftUI

struct CommentSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedComment: String
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack {
            // 상단 제목 + 닫기 버튼
            HStack {
                Text("코멘트")
                    .whereFont(.subtitle18semibold)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)

            // 선택된 코멘트 부분
            VStack {
                HStack {
                    Text(selectedComment)
                        .whereFont(.body16regular)
                        .lineLimit(4) // 최대 4줄까지 표시
                        .multilineTextAlignment(.leading) // 왼쪽 정렬
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.horizontal)
                    
                Spacer()
            }
            .padding(.top, 12)

            // 하단 버튼
            HStack {
                Button {
                    onDelete() // 삭제
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
                    onEdit() // 수정모드
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
