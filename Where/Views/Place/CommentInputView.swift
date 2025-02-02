//
//  CommentInputView.swift
//  Where
//
//  Created by 이현호 on 2/2/25.
//

import SwiftUI

struct CommentInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var commentText: String
    
    var onSubmit: () -> Void
    let placeholder: String = "친구들이 볼 수 있도록 코멘트를 달아보세요. (0/50)"
    
    var body: some View {
        VStack {
            // 상단 제목 + 닫기 버튼
            HStack {
                Text("코멘트 남기기")
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
                TextField(placeholder, text: $commentText, axis: .vertical)
                    .whereFont(.body16regular)
                    .lineLimit(4)
                    .foregroundStyle(.black)
                    .onChange(of: commentText) {
                        if commentText.count > 50 {
                            commentText = String(commentText.prefix(50)) // 50자 제한 적용
                        }
                    }
                
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
                    onSubmit()
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
