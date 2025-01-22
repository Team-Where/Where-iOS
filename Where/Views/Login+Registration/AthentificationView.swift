//
//  AthentificationView.swift
//  Where
//
//  Created by Swain Yun on 12/31/24.
//

import SwiftUI

struct AthentificationView: View {
    @ObservedObject private var viewModel = AthentificationViewModel()
    @State private var floater: FloaterType?
    
    @FocusState private var textFieldFocus: KeyboardFocusState?
    
    var body: some View {
        BasedFormView("가입을 위한 이메일을\n인증해주세요") {
            ScrollView(.vertical) {
                emailCell
                
                if viewModel.authorizationCodeValidationState == .valid {
                    passwordCell
                } else {
                    authorizationCodeCell
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .floater($floater) { type in
                switch type {
                case .authorizationCodeSended:
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                case .inValidAuthorizationCode:
                    Image(systemName: "exclamationmark.circle")
                        .foregroundStyle(.red)
                }
            }
        } footer: {
            Button {
                print("clicked")
                
                if viewModel.authorizationCodeValidationState == .valid {
                    // 인증코드 유효성 검사에 성공한 이후라면 비밀번호 설정
                    // TODO: 프로필 설정 화면으로 이동
                } else {
                    // 인증코드 유효성 검사에 성공하기 전이라면 인증코드 제출
                    // TODO: 인증코드 제출 기능
                    guard viewModel.authorizationCodeFieldText != "tlean code" else {
                        floater = .inValidAuthorizationCode
                        return
                    }
                    viewModel.authorizationCodeValidationState = .valid
                }
            } label: {
                Text("다음")
                    .whereFont(.body16semibold)
            }
            .buttonStyle(.whereRoundedProminent())
            .disabled(viewModel.isProceedButtonDisabled)
            .ignoresSafeArea(.keyboard)
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
                    text: $viewModel.emailFieldText,
                    lineColor: textFieldLineColor(focus: .emailTextField, invalid: viewModel.emailValidationState == .invalid)
                )
                .focused($textFieldFocus, equals: .emailTextField)
                .keyboardType(.emailAddress)
                
                authorizationCodeRequestButton(viewModel.emailValidationState)
                    .containerRelativeFrame(.horizontal, alignment: .trailing) { value, _ in
                        value - 26
                    }
            }
            
            if viewModel.emailValidationState == .invalid {
                Text("잘못된 이메일 주소입니다.")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0xEF4444))
            }
        }
    }
    
    @ViewBuilder private func authorizationCodeRequestButton(_ state: EmailValidationState) -> some View {
        switch state {
        case .beforeValidate, .invalid:
            Button {
                // TODO: 인증코드 요청
                floater = .authorizationCodeSended
                textFieldFocus = .authorizationCodeTextField
                viewModel.startTimer(seconds: 20)
            } label: {
                Text("인증코드 전송")
                    .whereFont(.caption12regular)
                    .foregroundStyle(Color(hex: 0xF2F5F5))
                    .frame(width: 84, height: 28)
                    .background(state == .invalid ? Color(hex: 0xDEE2E6) : Color(hex: 0x212529))
                    .clipShape(.capsule)
            }
            .disabled(viewModel.emailFieldText.isEmpty)
        case .valid:
            Button {
                // TODO: 인증코드 재요청
                floater = .authorizationCodeSended
                textFieldFocus = .authorizationCodeTextField
                viewModel.startTimer(seconds: 10)
            } label: {
                Text("재전송")
                    .whereFont(.caption12regular)
                    .foregroundStyle(Color(hex: 0xF2F5F5))
                    .frame(width: 52, height: 28)
                    .background(Color(hex: 0x1F2937))
                    .clipShape(.capsule)
            }
            .disabled(viewModel.emailFieldText.isEmpty)
        }
    }
    
    private var authorizationCodeCell: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("인증코드")
                .whereFont(.body14regular)
                .foregroundStyle(Color(hex: 0x374151))
            
            ZStack {
                RoundedTextField(
                    "코드 6자리 입력해주세요",
                    text: $viewModel.authorizationCodeFieldText,
                    lineColor: textFieldLineColor(focus: .authorizationCodeTextField, invalid: viewModel.authorizationCodeValidationState == .timeout)
                )
                .focused($textFieldFocus, equals: .authorizationCodeTextField)
                .keyboardType(.emailAddress)
                .textContentType(.oneTimeCode)
                
                timerCell(viewModel.remainingTime)
                    .containerRelativeFrame(.horizontal, alignment: .trailing) { value, _ in
                        value - 60
                    }
            }
            
            if viewModel.authorizationCodeValidationState == .timeout {
                Text("인증 시간이 만료되었습니다.")
                    .whereFont(.body14regular)
                    .foregroundStyle(.red)
            }
        }
    }
    
    @ViewBuilder private func timerCell(_ seconds: Int?) -> some View {
        if let time = seconds {
            let remainingTime = String(format: "%01d:%02d", time / 60, time % 60)
            
            Text(remainingTime)
                .whereFont(.body16regular)
                .foregroundStyle(seconds == .zero ? .red : .accent)
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
                    text: $viewModel.passwordFieldText,
                    lineColor: textFieldLineColor(focus: .passwordTextField, invalid: viewModel.passwordValidationState == .invalid)
                )
                .secured()
                .focused($textFieldFocus, equals: .passwordTextField)
                .textContentType(.oneTimeCode)
                
                if viewModel.passwordValidationState == .invalid {
                    Text("영문+숫자+특수문자(!,\\~,@) 조합 8~32자에 부합하지 않습니다.")
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0xEF4444))
                } else {
                    Text("영문+숫자+특수문자(!,\\~,@) 조합 8~32자")
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0x374151))
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("비밀번호")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x374151))
                
                RoundedTextField(
                    "비밀번호를 입력해주세요",
                    text: $viewModel.reInputPasswordFieldText,
                    lineColor: textFieldLineColor(focus: .reInputPasswordTextField, invalid: viewModel.passwordComparisonResult == .different)
                )
                .secured()
                .focused($textFieldFocus, equals: .reInputPasswordTextField)
                
                if viewModel.passwordComparisonResult == .different {
                    Text("비밀번호가 올바르지 않습니다.")
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0xEF4444))
                } else {
                    Text("비밀번호를 한 번 더 입력해주세요.")
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0x374151))
                }
            }
        }
    }
    
    private func textFieldLineColor(focus: KeyboardFocusState, invalid: Bool) -> Color {
        guard invalid == false else { return .red }
        return textFieldFocus == focus ? .accent : Color(hex: 0xE5E7EB)
    }
}

// MARK: Nested Types
extension AthentificationView {
    enum KeyboardFocusState: Hashable {
        case emailTextField, authorizationCodeTextField, passwordTextField, reInputPasswordTextField
    }
    
    enum FloaterType: FloaterContent {
        case authorizationCodeSended
        case inValidAuthorizationCode
        
        var title: String {
            switch self {
            case .authorizationCodeSended: "인증코드가 전송되었습니다."
            case .inValidAuthorizationCode: "인증코드가 잘못되었습니다."
            }
        }
    }
}

#Preview {
    NavigationStack {
        AthentificationView()
    }
}
