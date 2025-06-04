//
//  SignInView.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI
import Swinject

fileprivate typealias ProcessingState = SignInViewModel.ProcessingState

struct SignInView: View {
    @Binding var isLoginViewPresented: Bool
    @FocusState private var textFieldFocus: KeyboardFocusState?
    @State private var isPopupPresented: Bool = false
    @State private var emailFieldText = String()
    @State private var passwordFieldText = String()
    
    private var loginButtonDisabled: Bool {
        viewModel.state == .processing || emailFieldText.isEmpty || passwordFieldText.isEmpty
    }
    
    private let viewModel: SignInViewModel
    private let navigationTitle: String = "로그인을 해주세요"
    
    init(
        _ isLoginViewPresented: Binding<Bool>,
        resolver: Resolver
    ) {
        self._isLoginViewPresented = isLoginViewPresented
        self.viewModel = resolver.resolve(SignInViewModel.self)!
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("이메일")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x374151))
                
                RoundedTextField(
                    "이메일 주소를 입력해주세요",
                    text: $emailFieldText,
                    lineColor: Color(hex: 0xE5E7EB)
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
                    lineColor: Color(hex: 0xE5E7EB)
                )
                .secured()
                .focused($textFieldFocus, equals: .passwordTextField)
            }
        }
        .padding(.top, 40)
        .onChange(of: viewModel.state, onStateChange)
        .whereForm(navigationTitle) {
            Button {
                viewModel.login(email: emailFieldText, password: passwordFieldText)
            } label: {
                if viewModel.state == .processing {
                    ProgressView()
                        .frame(width: 350, height: 48)
                } else {
                    Text("로그인")
                        .whereFont(.body16semibold)
                        .frame(width: 350, height: 48)
                }
            }
            .buttonStyle(.whereRoundedProminent(disabled: loginButtonDisabled))
        }
        .clipShape(.rect)
        .onTapGesture {
            textFieldFocus = .none
        }
        .popup($isPopupPresented) {
            VStack(spacing: 22) {
                Text("이메일 또는 비밀번호를\n잘못 입력하셨습니다.")
                    .whereFont(.body14medium)
                    .foregroundStyle(Color(hex: 0x343A40))
                    .multilineTextAlignment(.center)
                
                Button {
                    isPopupPresented = false
                } label: {
                    Text("확인")
                        .whereFont(.body16semibold)
                        .frame(width: 270, height: 48)
                }
                .buttonStyle(.whereRoundedProminent())
            }
            .padding()
        }
    }
}

// MARK: - Methods
private extension SignInView {
    func onStateChange(_ : ProcessingState, after: ProcessingState) {
        switch after {
        case .fail: isPopupPresented = true
        case .success: isLoginViewPresented = false
        default: break
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
        SignInView(.constant(true), resolver: PreviewHelper.shared.resolver)
    }
}
