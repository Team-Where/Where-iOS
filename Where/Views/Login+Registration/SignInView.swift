//
//  SignInView.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI
import Swinject

struct SignInView: View {
    @FocusState private var textFieldFocus: KeyboardFocusState?
    @ObservedObject private var viewModel: SignInViewModel
    
    private let navigationTitle: String = "로그인을 해주세요"
    
    init(resolver: Resolver) {
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
                    text: $viewModel.emailFieldText,
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
                    text: $viewModel.passwordFieldText,
                    lineColor: Color(hex: 0xE5E7EB)
                )
                .secured()
                .focused($textFieldFocus, equals: .passwordTextField)
            }
        }
        .padding(.top, 40)
        .whereForm(navigationTitle) {
            Button {
                // TODO: 로그인
                viewModel.login()
            } label: {
                Text("로그인")
                    .whereFont(.body16semibold)
                    .frame(width: 350, height: 48)
            }
            .buttonStyle(.whereRoundedProminent())
        }
        .clipShape(.rect)
        .onTapGesture {
            textFieldFocus = .none
        }
        .popup($viewModel.isPopupPresented) {
            VStack(spacing: 22) {
                Text("이메일 또는 비밀번호를\n잘못 입력하셨습니다.")
                    .whereFont(.body14medium)
                    .foregroundStyle(Color(hex: 0x343A40))
                    .multilineTextAlignment(.center)
                
                Button {
                    viewModel.isPopupPresented = false
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

// MARK: Nested Types
extension SignInView {
    enum KeyboardFocusState: Hashable {
        case emailTextField, passwordTextField
    }
}

#Preview {
    NavigationStack {
        SignInView(resolver: PreviewHelper.shared.resolver)
    }
}
