//
//  CommentView.swift
//  Where
//
//  Created by 이현호 on 1/20/25.
//

import SwiftUI

struct CommentView: View {
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text("코멘트")
                
                Text("2")
                
                Spacer()
            }
            .whereFont(.body16medium)
            
            VStack {
                HStack {
                    Text("여기 웨이팅 맛집임")
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
                
                HStack {
                    Text("여기 야경 맛집임")
                        .whereFont(.body14regular)
                        .foregroundStyle(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: 0xE3E4E9), lineWidth: 1)
                        )
                    
                    Spacer()
                }
                
                HStack {
                    Text("그냥 그럼")
                        .whereFont(.body14regular)
                        .foregroundStyle(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: 0xE3E4E9), lineWidth: 1)
                        )
                    
                    Spacer()
                }
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}


#Preview {
    CommentView()
}
