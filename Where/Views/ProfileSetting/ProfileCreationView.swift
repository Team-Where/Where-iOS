//
//  ProfileCreationView.swift
//  Where
//
//  Created by 이현호 on 12/29/24.
//

import SwiftUI

struct ProfileCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State var username: String = ""
    @State private var isValid: Bool = false
    @State private var isPopupPresented = false
    @State private var profileImage: UIImage? = UIImage(named: "person") // 기본 이미지 설정
    @State private var shouldNavigate = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("프로필을 설정해주세요")
                .whereFont(.title24semibold)
                .padding(.top, 40)
            
            HStack {
                Spacer()
                
                ZStack(alignment: .bottomTrailing) {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 155, height: 155)
                            .clipShape(Circle())
                    }
                    Button {
                        withAnimation {
                            isPopupPresented = true
                        }
                    } label: {
                        Image("CameraButton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            .padding(.top, 58)
            
            VStack(alignment: .leading) {
                Text("닉네임")
                    .whereFont(.body14regular)
                    .padding(.top, 38)
                
                RoundedTextField(
                    "닉네임을 입력해주세요",
                    text: $username,
                    lineColor: !username.isEmpty && !isValid ? Color.red : (isValid ? Color.green : Color(hex: 0xE5E7EB))
                )
                .foregroundStyle(Color(hex: 0x6B7280))
                .background(
                    ZStack(alignment: .trailing) {
                        HStack {
                            Spacer()
                            
                            if isValid {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                                    .padding(.trailing, 30)
                            }
                        }
                    }
                )
                .onChange(of: username) { oldValue, newValue in
                    isValid = newValue.isValidNickname()
                }
                
                Text(isValid ? "사용 가능한 닉네임입니다" : "2~8자의 영문, 숫자, 한글, 특수문자(-, _)만 사용할 수 있습니다.")
                    .whereFont(.body14regular)
                    .foregroundColor(isValid ? .green : (username.isEmpty ? .black : .red))
                    .padding(.top, 8)
            }
            
            Spacer()
            
            Button {
                shouldNavigate = true
            } label: {
                Text("다음")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color(hex: 0x4F46E5) : Color(.systemGray5))
                    .foregroundStyle(.white)
                    .bold()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.vertical)
            .disabled(!isValid)
            .navigationDestination(isPresented: $shouldNavigate) {
                SignUpCompleteView(username: username)
            }
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
        }
    }
}


#Preview {
    NavigationStack {
        ProfileCreationView()
    }
}
