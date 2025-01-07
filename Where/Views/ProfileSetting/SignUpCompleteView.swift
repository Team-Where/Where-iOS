//
//  RegistrationCompleteView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI

struct SignUpCompleteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var shouldNavigate = false
    
    var username: String
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("\(username)님, \n회원가입을 축하합니다!")
                        .whereFont(.title24semibold)
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.horizontal)
                
                Image("SignUpCharacter")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 274.85, height: 264)
                    .padding(.top, 93)
                
                Spacer()
                
                Button {
                    shouldNavigate = true
                } label: {
                    Text("완료")
                        .frame(maxWidth: .infinity)
                        .padding()  // 버튼 내부 여백
                        .background(Color(hex: 0x4F46E5))  // 배경색 설정
                        .foregroundStyle(.white)  // 텍스트 색을 흰색으로 설정
                        .bold()
                        .cornerRadius(10)  // 둥근 모서리
                }
                .padding(.horizontal, 20)
                .padding(.vertical)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.backward")
                            .frame(width: 14, height: 12)
                            .foregroundStyle(.black)
                    }
                }
            }
            .navigationDestination(isPresented: $shouldNavigate) {
                TabBarView()
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    SignUpCompleteView(username: "") // Add preview parameter
}
