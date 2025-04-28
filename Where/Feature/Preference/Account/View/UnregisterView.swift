//
//  UnregisterView.swift
//  Where
//
//  Created by Swain Yun on 3/23/25.
//

import SwiftUI
import Swinject

fileprivate typealias UnregisterReasonType = UnregisterViewModel.UnregisterReasonType
fileprivate typealias UnregisterStep = UnregisterViewModel.UnregisterStep

struct UnregisterView: View {
    @ObservedObject private var viewModel: UnregisterViewModel
    
    init(resolver: Resolver) {
        self.viewModel = resolver.resolve(UnregisterViewModel.self)!
    }
    
    var body: some View {
        VStack {
            header(viewModel.unregisterStep)
                .whereFont(.title24semibold)
                .foregroundStyle(.where(.gray800))
                .multilineTextAlignment(.leading)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            content(viewModel.unregisterStep)
            
            Spacer()
            
            submitButton(viewModel.unregisterStep)
        }
        .padding(.horizontal)
        .padding(.top)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("계정 탈퇴")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            UnregisterConfirmationSheet(viewModel: viewModel)
        }
    }
    
    @ViewBuilder private func header(_ step: UnregisterStep) -> some View {
        switch step {
        case .submitUnregisterReason:
            HStack(alignment: .bottom, spacing: 0) {
                Text("어디를\n떠나는")
                Text(" 이유")
                    .foregroundStyle(.accent)
                Text("가 있을까요?")
            }
            
        case .unregisterComplete:
            Text("탈퇴 처리가\n완료되었습니다.")
        }
    }
    
    @ViewBuilder private func content(_ step: UnregisterStep) -> some View {
        switch step {
        case .submitUnregisterReason:
            radioButtonsSection
        case .unregisterComplete:
            HStack {
                Text("그동안 어디를 이용해주셔서 감사합니다.")
                    .whereFont(.body16regular)
                    .foregroundStyle(.where(.gray800))
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder private func submitButton(_ step: UnregisterStep) -> some View {
        switch step {
        case .submitUnregisterReason:
            confirmButton
        case .unregisterComplete:
            completeButton
        }
    }
    
    private var radioButtonsSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 32) {
                ForEach(UnregisterReasonType.allCases) { reason in
                    RadioButton(selectedValue: $viewModel.selectedUnregisterReason, value: reason)
                }
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    private var confirmButton: some View {
        Button {
            viewModel.presentUnregisterConfirmationSheet()
        } label: {
            Text("확인")
                .whereFont(.body16medium)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.whereRoundedProminent())
    }
    
    private var completeButton: some View {
        Button {
            dismiss()
        } label: {
            Text("완료")
                .whereFont(.body16medium)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.whereRoundedProminent())
    }
}

// MARK: Subviews
extension UnregisterView {
    struct UnregisterConfirmationSheet: View {
        @ObservedObject private var viewModel: UnregisterViewModel
        
        init(viewModel: UnregisterViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack {
                VStack(spacing: 13) {
                    Text(UnregisterViewModel.Constants.confirmationTitleScript)
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(.where(.gray800))
                    
                    Text(UnregisterViewModel.Constants.confirmationContentScript)
                        .whereFont(.body16regular)
                        .foregroundStyle(.where(.gray600))
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Spacer()
                
                HStack {
                    Button {
                        viewModel.dismissUnregisterConfirmationSheet()
                    } label: {
                        Text("취소")
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color(hex: 0x4B5563))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: 0xF3F4F6))
                    )
                    
                    Button {
                        viewModel.unregister()
                    } label: {
                        Text("확인")
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.accent)
                    )
                }
            }
            .padding()
            .presentationDetents([.fraction(0.4)])
            .presentationCornerRadius(16)
        }
    }
}
