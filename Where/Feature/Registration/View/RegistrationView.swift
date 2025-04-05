//
//  RegistrationView.swift
//  Where
//
//  Created by Swain Yun on 12/31/24.
//

import SwiftUI
import Swinject

struct RegistrationView: View {
    @ObservedObject private var viewModel: RegistrationViewModel
    @Binding var isLoginNeeded: Bool
    @FocusState private var textFieldFocus: KeyboardFocusState?
    
    init(
        _ isLoginNeeded: Binding<Bool>,
        resolver: Resolver
    ) {
        self._isLoginNeeded = isLoginNeeded
        self.viewModel = resolver.resolve(RegistrationViewModel.self)!
    }
    
    var body: some View {
        content()
            .padding(.top, 40)
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
                    Text(viewModel.proceedButtonLabel())
                        .whereFont(.body16semibold)
                        .frame(width: 350, height: 48)
                }
                .buttonStyle(.whereRoundedProminent(disabled: viewModel.isProceedButtonDisabled))
                .ignoresSafeArea(.keyboard)
            }
            .popup($viewModel.isPopupPresented) {
                ImageSelectionPopupView(isPopupPresented: $viewModel.isPopupPresented) { uiImage in
                    viewModel.profileImage = uiImage
                }
            }
            .onDisappear {
                viewModel.flush()
            }
            .onChange(of: viewModel.isCompleted) { _, isCompleted in
                guard isCompleted else { return }
                isLoginNeeded = false
            }
    }
    
    @ViewBuilder private func content() -> some View {
        switch viewModel.registrationStep {
        case .email:
            ScrollView(.vertical) {
                emailCell
                
                authorizationCodeCell
                
                Spacer()
            }
        case .password:
            ScrollView(.vertical) {
                emailCell
                
                passwordCell
                
                Spacer()
            }
        case .profile:
            ScrollView(.vertical) {
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
                            viewModel.isPopupPresented = true
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
                
                nicknameCell()
            }
        case .completed:
            VStack {
                Image("SignUpCharacter")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 274.85, height: 264)
                    .padding(.top, 40)
            }
        }
    }
    
    private var emailCell: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이메일")
                .whereFont(.body14regular)
                .foregroundStyle(Color(hex: 0x374151))
            
            ZStack(alignment: .trailing) {
                RoundedTextField(
                    "이메일 주소를 입력해주세요",
                    text: $viewModel.emailFieldText,
                    lineColor: textFieldLineColor(focus: .emailTextField)
                )
                .frame(width: 350)
                .focused($textFieldFocus, equals: .emailTextField)
                .keyboardType(.emailAddress)
                
                authorizationCodeRequestButton(viewModel.emailValidationState)
                    .padding(.trailing)
            }
            
            if viewModel.emailValidationState == .invalid {
                Text("잘못된 이메일 주소입니다.")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0xEF4444))
            }
        }
        .padding(.bottom)
    }
    
    @ViewBuilder private func authorizationCodeRequestButton(_ state: EmailValidationState) -> some View {
        switch state {
        case .beforeValidate, .invalid:
            Button {
                viewModel.requestAuthorizationCode()
                textFieldFocus = .authorizationCodeTextField
                viewModel.startTimer(seconds: 20)
            } label: {
                Text("인증코드 전송")
                    .whereFont(.caption12regular)
                    .foregroundStyle(Color(hex: 0xF2F5F5))
                    .frame(width: 84, height: 28)
                    .background(state == .invalid ? Color(hex: 0xADB5BD) : Color(hex: 0x212529))
                    .clipShape(.capsule)
            }
            .disabled(viewModel.emailFieldText.isEmpty)
        case .valid:
            Button {
                // TODO: 인증코드 재요청
                viewModel.requestAuthorizationCode()
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
            
            ZStack(alignment: .trailing) {
                RoundedTextField(
                    "코드 6자리 입력해주세요",
                    text: $viewModel.authorizationCodeFieldText,
                    lineColor: textFieldLineColor(focus: .authorizationCodeTextField)
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
                    lineColor: textFieldLineColor(focus: .passwordTextField)
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
                    lineColor: textFieldLineColor(focus: .reInputPasswordTextField)
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
    
    @ViewBuilder private func nicknameCell() -> some View {
        VStack(alignment: .leading) {
            Text("닉네임")
                .whereFont(.body14regular)
                .foregroundStyle(.where(.gray700))
                .padding(.top, 38)
            
            RoundedTextField(
                "닉네임을 입력해주세요",
                text: $viewModel.nicknameFieldText,
                lineColor: textFieldLineColor(focus: .nicknameTextField)
            )
            .foregroundStyle(Color(hex: 0x6B7280))
            .background(
                ZStack(alignment: .trailing) {
                    HStack {
                        Spacer()
                        
                        if viewModel.nicknameValidationState == .valid {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .padding(.trailing, 30)
                        }
                    }
                }
            )
            
            Text(viewModel.nicknameValidationNotice())
                .whereFont(.body14regular)
                .foregroundColor(viewModel.nicknameValidationNoticeColor())
                .padding(.top, 8)
        }
    }
    
    private func textFieldLineColor(focus: KeyboardFocusState) -> Color {
        var isInvalid: Bool
        
        switch focus {
        case .emailTextField:
            isInvalid = viewModel.emailValidationState == .invalid
        case .authorizationCodeTextField:
            isInvalid = viewModel.authorizationCodeValidationState == .timeout
        case .passwordTextField:
            isInvalid = viewModel.passwordValidationState == .invalid
        case .reInputPasswordTextField:
            isInvalid = viewModel.passwordComparisonResult == .different
        case .nicknameTextField:
            isInvalid = viewModel.nicknameValidationState == .duplicated || viewModel.nicknameValidationState == .invalid
        }
        
        guard isInvalid == false else { return .red }
        return textFieldFocus == focus ? .accent : Color(hex: 0xE5E7EB)
    }
}

// MARK: Nested Types
extension RegistrationView {
    enum KeyboardFocusState: Hashable {
        case emailTextField, authorizationCodeTextField, passwordTextField, reInputPasswordTextField, nicknameTextField
    }
}

#Preview {
    NavigationStack {
        RegistrationView(.constant(true), resolver: PreviewHelper.shared.resolver)
    }
}
