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
    @State private var showPopup = false
    @State private var profileImage: UIImage? = UIImage(named: "person")
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Text("프로필을 설정해주세요")
                            .font(.system(size: 24.0))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.top, 40)
                    .padding(.horizontal)
                    
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
                                showPopup = true
                            }
                        } label: {
                            Image("CameraButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 58)
                    
                    HStack {
                        Text("닉네임")
                        Spacer()
                    }
                    .padding(.top, 38)
                    .padding(.horizontal)
                    
                    ZStack(alignment: .trailing) {
                        // 팝업창
                        TextField("",
                                  text: $username,
                                  prompt: Text("닉네임을 입력해주세요").foregroundStyle(Color(hex: 0x6B7280))
                        )
                        .frame(height: 56)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding([.horizontal], 15)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isValid ? Color.green : Color(hex: 0xE5E7EB)))
                        .padding(.horizontal)
                        .onChange(of: username) { newValue in
                            // 텍스트 필드가 비어 있으면 isValid를 false로 설정
                            if newValue.isEmpty {
                                isValid = false
                            } else {
                                // 8자 이상 입력 제한
                                let maxLength = 8
                                let filteredValue = newValue.filter { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "_" }
                                
                                // 8자 이상일 경우 8자까지만 잘라내기
                                username = String(filteredValue.prefix(maxLength))
                                
                                // 유효성 검사: 특수문자, 이모지 제외
                                isValid = username.count <= maxLength && !username.containsEmoji && username.allSatisfy {
                                    $0.isLetter || $0.isNumber || $0 == "-" || $0 == "_"
                                }
                            }
                        }
                        
                        // 체크 아이콘
                        if isValid {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .padding(.trailing, 30)
                        }
                    }
                    
                    
                    HStack {
                        Text(isValid ? "사용 가능한 닉네임입니다" : "8자 내, 이모지, 특수문자(-,_제외)를 사용할 수 없습니다.")
                            .font(.system(size: 14))
                            .foregroundColor(isValid ? .green : .black)  // 유효성에 따라 색상 변경
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Button {
                        // 버튼 클릭 시 동작할 코드
                    } label: {
                        Text("다음")
                            .frame(maxWidth: .infinity)
                            .padding()  // 버튼 내부 여백
                            .background(Color(hex: 0x4F46E5))  // 배경색 설정
                            .foregroundStyle(.white)  // 텍스트 색을 흰색으로 설정
                            .bold()
                            .cornerRadius(10)  // 둥근 모서리
                    }
                    .padding()
                }
                
                if showPopup {
                    ProfilePopupView(showPopup: $showPopup, profileImage: $profileImage)
                }
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
        }
    }
}


#Preview {
    ProfileCreationView()
}
