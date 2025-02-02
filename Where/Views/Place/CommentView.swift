//
//  CommentView.swift
//  Where
//
//  Created by 이현호 on 1/20/25.
//

import SwiftUI

struct CommentView: View {
    @State private var comments: [String] = []
    @State private var commentText: String = ""
    @State private var isShowingCommentSheet: Bool = false
    
    var body: some View {
        VStack {
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
                    .foregroundStyle(Color(hex: 0x4F46E5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color(hex: 0xDEE2E6), lineWidth: 1)
                    )
            }
            
            VStack {
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
                        
                        Spacer()
                    }
                }
            }
            .padding(.top, 16)
            
            HStack {
                TextField("코멘트 남기기", text: $commentText) {
                    if !commentText.isEmpty {
                        comments.append(commentText)
                        commentText = ""
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}


#Preview {
    CommentView()
}
