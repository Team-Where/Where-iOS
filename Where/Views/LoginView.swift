//
//  LoginView.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("약속을 새롭게 정의하다")
                .whereFont(.subtitle18semibold)
                .padding()
            
            Image(.logo)
            
            Spacer()
            
            Image(.glassfyingCharacter)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Spacer()
            
            VStack(spacing: 20) {
                // Start With Naver Button
                Button {
                    // TODO: 네이버 OAuth API 연결
                } label: {
                    Image(.startWithNaver)
                        .resizable()
                        .scaledToFit()
                }
                
                // Start With Kakao Button
                Button {
                    // TODO: 카카오 OAuth API 연결
                } label: {
                    Image(.startWithKakao)
                        .resizable()
                        .scaledToFit()
                }
                
                // Start With Apple Button
                Button {
                    // TODO: 애플 Authenficiation 연결
                } label: {
                    Image(.startWithApple)
                        .resizable()
                        .scaledToFit()
                }
                
                // Start With E-mail Button
                Button {
                    
                } label: {
                    Text("이메일로 시작하기")
                        .whereFont(.body16semibold)
                }
                .buttonStyle(.whereRoundedProminent())
                
                HStack {
                    Text("이미 계정 있나요?")
                        .whereFont(.body14medium)
                    
                    Button {
                        
                    } label: {
                        Text("여기에 로그인하세요")
                            .whereFont(.body14medium)
                            .underline()
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                backButton
            }
        }
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .frame(width: 12, height: 12)
                .padding()
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
