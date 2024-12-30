//
//  SignInView.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI

struct SignInView: View {
    @State private var emailFieldText: String = String()
    @State private var passwordFieldText: String = String()
    @State private var isPopupPresented: Bool = false
    @FocusState private var textFieldFocus: KeyboardFocusState?
    
    var body: some View {
        BasedFormView("로그인을 해주세요") {
            Spacer()
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("이메일")
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0x374151))
                    
                    RoundedTextField(
                        "이메일 주소를 입력해주세요",
                        text: $emailFieldText,
                        color: Color(hex: 0xE5E7EB)
                    )
                    .focused($textFieldFocus, equals: .emailTextField)
                    .keyboardType(.emailAddress)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("비밀번호")
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0x374151))
                    
                    RoundedTextField(
                        "비밀번호를 입력해주세요",
                        text: $passwordFieldText,
                        color: Color(hex: 0xE5E7EB),
                        isSecured: true
                    )
                    .focused($textFieldFocus, equals: .passwordTextField)
                }
            }
            
            Spacer()
        } footer: {
            Button {
                // TODO: 로그인
                // 1. API 통해 인증 과정
                // 2. 응답에 따라 팝업 표시 등 추후 작업
                withAnimation {
                    isPopupPresented = true
                }
            } label: {
                Text("로그인")
                    .whereFont(.body16semibold)
            }
            .buttonStyle(.whereRoundedProminent())
        }
        .clipShape(.rect)
        .onTapGesture {
            textFieldFocus = .none
        }
        .popup($isPopupPresented) {
            VStack(spacing: 20) {
                Text("이메일 또는 비밀번호를\n잘못 입력하셨습니다.")
                    .padding()
                
                Button {
                    isPopupPresented = false
                } label: {
                    Text("확인")
                        .whereFont(.body16semibold)
                }
                .buttonStyle(.whereRoundedProminent())
            }
            .padding()
        }
    }
}

// MARK: Nested Types
extension SignInView {
    enum KeyboardFocusState: Hashable {
        case emailTextField, passwordTextField
    }
}

#Preview {
    NavigationStack {
        SignInView()
    }
}
