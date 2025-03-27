//
//  EditProfileView.swift
//  Where
//
//  Created by Swain Yun on 3/25/25.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject private var viewModel: EditProfileViewModel
    
    init(_ user: User) {
        self.viewModel = EditProfileViewModel(user: user)
    }
    
    var body: some View {
        ZStack {
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    if let image = viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 155, height: 155)
                            .clipShape(Circle())
                    }
                    
                    Button {
                        withAnimation {
                            viewModel.showPopup()
                        }
                    } label: {
                        Image("CameraButton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("닉네임")
                            .whereFont(.body14regular)
                            .foregroundStyle(.where(hex: 0x374151))
                        
                        RoundedTextField(
                            "닉네임을 입력해주세요",
                            text: $viewModel.nicknameFieldText,
                            lineColor: Color(hex: 0xE5E7EB)
                        )
                    }
                    
                    // TODO: 이메일 검증 과정 및 추가 화면 필요(WIP)
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("이메일 주소")
//                            .whereFont(.body14regular)
//                            .foregroundStyle(.where(hex: 0x374151))
//                        
//                        RoundedTextField(
//                            "비밀번호를 입력해주세요",
//                            text: $emailFieldText,
//                            lineColor: Color(hex: 0xE5E7EB)
//                        )
//                        .keyboardType(.emailAddress)
//                    }
                    
                    Text(viewModel.isNicknameValid ? "사용 가능한 닉네임입니다" : "2~8자의 영문, 숫자, 한글, 특수문자(-, _)만 사용할 수 있습니다.")
                        .whereFont(.body14regular)
                        .foregroundColor(viewModel.isNicknameValid ? .green : (viewModel.nicknameFieldText.isEmpty ? .black : .red))
                }
                .padding()
                .padding(.top)
            }
            
            if viewModel.isPopupPresented {
                ProfilePopupView(showPopup: $viewModel.isPopupPresented, profileImage: $viewModel.profileImage)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .navigation) {
                Text("프로필 수정")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("완료") {
                    // TODO: 프로필 수정 기능 연결
                }
                .disabled(viewModel.isNicknameValid == false)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView(.init())
    }
}
