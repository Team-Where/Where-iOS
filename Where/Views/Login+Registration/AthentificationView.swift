//
//  AthentificationView.swift
//  Where
//
//  Created by Swain Yun on 12/31/24.
//

import SwiftUI

struct AthentificationView: View {
    @State private var isToastPresented: Bool = false
    @State private var emailFieldText: String = String()
    @State private var authorizationCodeFieldText: String = String()
    @State private var passwordFieldText: String = String()
    @State private var reInputPasswordFieldText: String = String()
    @FocusState private var textFieldFocus: KeyboardFocusState?
    
    var body: some View {
        BasedFormView("가입을 위한 이메일을\n인증해주세요") {
            VStack(spacing: 20) {
                emailCell
                
//                authorizationCodeCell
                
                passwordCell
                
                Spacer()
            }
            .padding(.top, 40)
            .floater($isToastPresented, message: "인증코드가 전송되었습니다.")
        } footer: {
            NavigationLink {
                // TODO: 비밀번호 작성 화면으로 이동? 프로필 설정 화면으로 이동?
            } label: {
                Text("다음")
                    .whereFont(.body16semibold)
            }
            .buttonStyle(.whereRoundedProminent(true))
        }
    }
    
    private var emailCell: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이메일")
                .whereFont(.body14regular)
                .foregroundStyle(Color(hex: 0x374151))
            
            ZStack {
                RoundedTextField(
                    "이메일 주소를 입력해주세요",
                    text: $emailFieldText,
                    color: Color(hex: 0xE5E7EB)
                )
                .focused($textFieldFocus, equals: .emailTextField)
                .keyboardType(.emailAddress)
                
                // TODO: 전송 여부에 따라 컴포넌트 바뀌어야함
                Button {
                    // TODO: 인증코드 요청
                    isToastPresented = true
                    textFieldFocus = .authorizationCodeTextField
                } label: {
                    Text("인증코드 전송")
                        .whereFont(.caption12regular)
                        .foregroundStyle(Color(hex: 0xF2F5F5))
                        .frame(width: 84, height: 26)
                        .padding(3)
                        .background(Color(hex: 0x9CA3AF))
                        .clipShape(.capsule)
                }
                .containerRelativeFrame(.horizontal, alignment: .trailing) { value, _ in
                    value - 60
                }
                
                // TODO: 전송 여부에 따라 컴포넌트 바뀌어야함
                Text("전송 완료")
                    .whereFont(.caption12regular)
                    .foregroundStyle(Color(hex: 0xF2F5F5))
                    .frame(width: 65, height: 26)
                    .padding(3)
                    .background(Color(hex: 0x1F2937))
                    .clipShape(.capsule)
                    .containerRelativeFrame(.horizontal, alignment: .trailing) { value, _ in
                        value - 60
                    }
                
            }
            
            // TODO: Email Validation Check
            Text("잘못된 이메일 주소입니다.")
                .whereFont(.body14regular)
                .foregroundStyle(Color(hex: 0xEF4444))
        }
    }
    
    private var authorizationCodeCell: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("인증코드")
                .whereFont(.body14regular)
                .foregroundStyle(Color(hex: 0x374151))
            
            HStack {
                RoundedTextField(
                    "코드 6자리 입력해주세요",
                    text: $authorizationCodeFieldText,
                    color: /*Color(hex: 0xE5E7EB)*/ .red
                )
                .focused($textFieldFocus, equals: .authorizationCodeTextField)
                
                // TODO: 등장 조건?
                Text("재전송")
                    .padding(20)
                    .whereFont(.body16regular)
                    .overlay(alignment: .center) {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: 0xE5E7EB))
                    }
            }
            
            // TODO: Code Validation Check
            Text("인증코드가 올바르지 않습니다.")
                .whereFont(.body14regular)
                .foregroundStyle(Color(hex: 0xEF4444))
        }
    }
    
    private var passwordCell: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("비밀번호")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x374151))
                
                RoundedTextField(
                    "비밀번호를 입력해주세요",
                    text: $passwordFieldText,
                    color: /*Color(hex: 0xE5E7EB)*/ .red,
                    isSecured: true
                )
                .focused($textFieldFocus, equals: .passwordTextField)
                
                Text("영문+숫자+특수문자(!,\\~,@) 조합 8~32자")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x374151))
                
                // TODO: Password Validation Check
                Text("영문+숫자+특수문자(!,\\~,@) 조합 8~32자에 부합하지 않습니다.")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0xEF4444))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("비밀번호")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x374151))
                
                RoundedTextField(
                    "비밀번호를 입력해주세요",
                    text: $reInputPasswordFieldText,
                    color: Color(hex: 0xE5E7EB),
                    isSecured: true
                )
                .focused($textFieldFocus, equals: .reInputPasswordTextField)
                
                Text("비밀번호를 한 번 더 입력해주세요.")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x374151))
                
                // TODO: Password Validation Check
                Text("비밀번호가 올바르지 않습니다.")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0xEF4444))
            }
        }
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
        // 8~32자
        guard (8...32).contains(password.count) else { return false }
        
        // 영문, 숫자, 특수문자("!", "~", "@") 포함
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigits = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecialCharacters = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!~@")) != nil
        
        return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters
    }
}

// MARK: Nested Types
extension AthentificationView {
    enum KeyboardFocusState: Hashable {
        case emailTextField, authorizationCodeTextField, passwordTextField, reInputPasswordTextField
    }
}

#Preview {
    AthentificationView()
}
