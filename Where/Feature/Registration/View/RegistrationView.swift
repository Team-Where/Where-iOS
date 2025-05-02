//
//  RegistrationView.swift
//  Where
//
//  Created by Swain Yun on 12/31/24.
//

import SwiftUI
import Swinject

fileprivate typealias KeyboardFocusState = RegistrationViewModel.KeyboardFocusState

struct RegistrationView: View {
    @ObservedObject private var viewModel: RegistrationViewModel
    @Binding var isLoginNeeded: Bool
    @FocusState private var textFieldFocus: KeyboardFocusState?
    
    private let resolver: Resolver
    
    init(
        _ isLoginNeeded: Binding<Bool>,
        resolver: Resolver
    ) {
        self._isLoginNeeded = isLoginNeeded
        self.viewModel = resolver.resolve(RegistrationViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            emailCell()
            
            if viewModel.registrationStep == .email {
                authorizationCodeCell()
            } else {
                passwordCell
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .floater($viewModel.floater) { type in
            switch type {
            case .authorizationCodeSended:
                Image(systemName: "checkmark")
                    .foregroundStyle(.accent)
            case .inValidAuthorizationCode:
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
            }
        }
        .whereForm(viewModel.navigationTitle) {
            Button {
                viewModel.proceed()
            } label: {
                Text("다음")
                    .whereFont(.body16semibold)
                    .frame(width: 350, height: 48)
            }
            .buttonStyle(.whereRoundedProminent(disabled: viewModel.isProceedButtonDisabled))
            .ignoresSafeArea(.keyboard)
        }
        .navigationDestination(isPresented: $viewModel.isCompleted) {
            ProfileCreationView($isLoginNeeded, resolver: resolver)
        }
    }
    
    @ViewBuilder private func emailCell() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이메일")
                .whereFont(.body14regular)
                .foregroundStyle(Color(hex: 0x374151))
            
            ZStack(alignment: .trailing) {
                RoundedTextField(
                    "이메일 주소를 입력해주세요",
                    text: $viewModel.emailFieldText,
                    lineColor: .where(hex: viewModel.textFieldLineColorHex(currentFocused: textFieldFocus, focus: .emailTextField))
                )
                .frame(width: 350)
                .focused($textFieldFocus, equals: .emailTextField)
                .keyboardType(.emailAddress)
                
                authorizationCodeRequestButton(viewModel.emailValidationState)
                    .padding(.trailing)
            }
            
            Text(viewModel.emailValidationNotice)
                .whereFont(.body14regular)
                .foregroundStyle(Color(hex: 0xEF4444))
        }
        .padding(.top, 40)
        .padding(.bottom)
    }
    
    @ViewBuilder private func authorizationCodeRequestButton(_ state: EmailValidationState) -> some View {
        switch state {
        case .beforeValidate, .invalidOnLocal, .emailDuplicated:
            Button {
                viewModel.requestAuthorizationCode()
            } label: {
                Text("인증코드 전송")
                    .whereFont(.caption12regular)
                    .foregroundStyle(Color(hex: 0xF2F5F5))
                    .frame(width: 84, height: 28)
                    .background(state == .invalidOnLocal ? Color(hex: 0xADB5BD) : Color(hex: 0x212529))
                    .clipShape(.capsule)
            }
            .disabled(viewModel.requestAuthorizationCodeDisabled)
        case .valid:
            Button {
                viewModel.requestAuthorizationCode()
                textFieldFocus = .authorizationCodeTextField
            } label: {
                Text("재전송")
                    .whereFont(.caption12regular)
                    .foregroundStyle(Color(hex: 0xF2F5F5))
                    .frame(width: 52, height: 28)
                    .background(Color(hex: 0x1F2937))
                    .clipShape(.capsule)
            }
            .disabled(viewModel.requestAuthorizationCodeDisabled)
        }
    }
    
    @ViewBuilder private func authorizationCodeCell() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("인증코드")
                .whereFont(.body14regular)
                .foregroundStyle(Color(hex: 0x374151))
            
            ZStack(alignment: .trailing) {
                RoundedTextField(
                    "코드 6자리 입력해주세요",
                    text: $viewModel.authorizationCodeFieldText,
                    lineColor: .where(hex: viewModel.textFieldLineColorHex(currentFocused: textFieldFocus, focus: .authorizationCodeTextField))
                )
                .frame(width: 350)
                .focused($textFieldFocus, equals: .authorizationCodeTextField)
                .keyboardType(.emailAddress)
                .textContentType(.oneTimeCode)
                
                timerCell(viewModel.remainingTime)
                    .padding(.trailing)
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
                    lineColor: .where(hex: viewModel.textFieldLineColorHex(currentFocused: textFieldFocus, focus: .passwordTextField))
                )
                .secured()
                .frame(width: 350)
                .focused($textFieldFocus, equals: .passwordTextField)
                
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
            .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("비밀번호")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x374151))
                
                RoundedTextField(
                    "비밀번호를 입력해주세요",
                    text: $viewModel.reInputPasswordFieldText,
                    lineColor: .where(hex: viewModel.textFieldLineColorHex(currentFocused: textFieldFocus, focus: .reInputPasswordTextField))
                )
                .secured()
                .frame(width: 350)
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
}

#Preview {
    RegistrationView(.constant(true), resolver: PreviewHelper.shared.resolver)
}
