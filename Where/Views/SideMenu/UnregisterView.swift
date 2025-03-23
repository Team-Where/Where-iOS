//
//  UnregisterView.swift
//  Where
//
//  Created by Swain Yun on 3/23/25.
//

import SwiftUI

struct UnregisterView: View {
    struct Constants {
        static let confirmationTitleScript: String = "잠깐만요"
        static let confirmationContentScript: String = "탈퇴 시 계정 및 이용 기록은 모두 삭제되며,\n삭제된 데이터는 복구가 불가능합니다.\n또한 탈퇴 후 동일 계정으로 재가입시\n제한을 받을 수 있습니다.\n탈퇴를 진행할까요?"
    }
    
    @State private var selectedUnregisterReason: UnregisterReasonType?
    @State private var unregisterStep: UnregisterStep = .submitUnregisterReason
    @State private var isSheetPresented: Bool = false
    
    
    private var disabled: Bool { selectedUnregisterReason == nil }
    
    var body: some View {
        VStack {
            header(unregisterStep)
                .whereFont(.title24semibold)
                .foregroundStyle(.where(.gray800))
                .multilineTextAlignment(.leading)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            content(unregisterStep)
            
            Spacer()
            
            submitButton(unregisterStep)
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
        .sheet(isPresented: $isSheetPresented) {
            UnregisterConfirmationSheet($isSheetPresented, step: $unregisterStep)
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
                    RadioButton(selectedValue: $selectedUnregisterReason, value: reason)
                }
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    private var confirmButton: some View {
        Button {
            // TODO: 탈퇴 사유 제출 및 회원탈퇴 요청
            isSheetPresented = true
        } label: {
            Text("확인")
                .whereFont(.body16medium)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.whereRoundedProminent(disabled: disabled))
    }
    
    private var completeButton: some View {
        Button {
            // TODO: 탈퇴 과정 종료 및 앱 내 잔여 회원정보 정리 등
        } label: {
            Text("완료")
                .whereFont(.body16medium)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.whereRoundedProminent())
    }
}

// MARK: Nested Types
extension UnregisterView {
    enum UnregisterReasonType: String, RadioButtonSelection {
        case infrequentUse = "사용을 잘 안해서"
        case frequentErrors = "잦은 오류, 장애가 발생해서"
        case difficultyOfUse = "이용 방법이 어려워서"
        case other = "기타"
        
        var title: String {
            self.rawValue
        }
    }
    
    /// 회원탈퇴 과정의 단계를 의미합니다.
    enum UnregisterStep {
        /// 탈퇴 사유 제출
        case submitUnregisterReason
        /// 탈퇴 처리 완료
        case unregisterComplete
    }
    
    struct UnregisterConfirmationSheet: View {
        @Binding var isSheetPresented: Bool
        @Binding var unregisterStep: UnregisterStep
        
        init(
            _ isSheetPresented: Binding<Bool>,
            step: Binding<UnregisterStep>
        ) {
            self._isSheetPresented = isSheetPresented
            self._unregisterStep = step
        }
        
        var body: some View {
            VStack {
                VStack(spacing: 13) {
                    Text(Constants.confirmationTitleScript)
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(.where(.gray800))
                    
                    Text(Constants.confirmationContentScript)
                        .whereFont(.body16regular)
                        .foregroundStyle(.where(.gray600))
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Spacer()
                
                HStack {
                    Button {
                        isSheetPresented = false
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
                        // TODO: 탈퇴 처리 및 앱 내 잔여 회원정보 정리 등
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isSheetPresented = false
                            unregisterStep = .unregisterComplete
                        }
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

#Preview {
    NavigationStack {
        UnregisterView()
    }
}
