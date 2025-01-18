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
            VStack(alignment: .leading) {
                Text("\(username)님, \n회원가입을 축하합니다!")
                    .whereFont(.title24semibold)
                    .padding(.top, 40)
                
                HStack {
                    Spacer()
                    
                    Image("SignUpCharacter")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 274.85, height: 264)
                    
                    Spacer()
                }
                .padding(.top, 93)
                
                Spacer()
                
                Button {
                    shouldNavigate = true
                } label: {
                    Text("완료")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: 0x4F46E5))
                        .foregroundStyle(.white)
                        .bold()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.vertical)
                .navigationDestination(isPresented: $shouldNavigate) {
                    TabBarView()
                }
            }
            .padding(.horizontal, 20)
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
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    SignUpCompleteView(username: "")
}
