//
//  AdjustPasswordView.swift
//  Where
//
//  Created by Swain Yun on 1/22/25.
//

import SwiftUI

struct AdjustPasswordView: View {
    @ObservedObject private var viewModel = AdjustPasswordViewModel()
    
    @FocusState private var textFieldFocus: KeyboardFocusState?
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
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
                .frame(width: 350)
                .padding(.bottom)
                
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
                .frame(width: 350)
            }
            
            Button {
                // TODO: 비밀번호 변경 요청
            } label: {
                Text("완료")
                    .whereFont(.body16semibold)
                    .frame(width: 350, height: 48)
            }
            .buttonStyle(.whereRoundedProminent(viewModel.isDoneButtomDisabled))
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("비밀번호 변경")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(Color(hex: 0x1F2937))
            }
        }
        .padding()
    }
    
    private func textFieldLineColor(focus: KeyboardFocusState, invalid: Bool) -> Color {
        guard invalid == false else { return .red }
        return textFieldFocus == focus ? .accent : Color(hex: 0xE5E7EB)
    }
}

// MARK: Nested Types
extension AdjustPasswordView {
    enum KeyboardFocusState {
        case passwordTextField
        case reInputPasswordTextField
    }
}

#Preview {
    NavigationStack {
        AdjustPasswordView()
    }
}
