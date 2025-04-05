//
//  CommentEditView.swift
//  Where
//
//  Created by 이현호 on 2/8/25.
//

import SwiftUI

struct CommentEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var commentText: String
    var onUpdate: () -> Void // 수정 완료 시 실행될 클로저
    
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

            // 입력된 코멘트 부분
            VStack {
                HStack {
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
                .padding(.horizontal)
                    
                Spacer()
            }
            .padding(.top, 12)

            // 하단 버튼
            HStack {
                Button {
                    dismiss()
                } label: {
                    RoundedRectangle(cornerSize: .init(width: 16, height: 16))
                        .overlay {
                            Text("취소")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                        }
                }
                .frame(width: 169, height: 54)
                .foregroundStyle(Color(hex: 0xF3F4F6))
                .transition(.opacity)

                Button {
                    onUpdate() // 코멘트 업데이트
                    dismiss()
                } label: {
                    RoundedRectangle(cornerSize: .init(width: 16, height: 16))
                        .overlay {
                            Text("확인")
                                .whereFont(.body16medium)
                                .foregroundStyle(.white)
                        }
                }
                .frame(width: 169, height: 54)
                .foregroundStyle(Color(hex: 0x4F46E5))
                .transition(.opacity)
            }
        }
        .padding()
    }
}
