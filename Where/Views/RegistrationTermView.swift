//
//  RegistrationTermView.swift
//  Where
//
//  Created by Swain Yun on 12/31/24.
//

import SwiftUI

struct RegistrationTermView: View {
    @State private var isAllSelected: Bool = true
    @State private var ageLimitSelected: Bool = true
    @State private var agreeToTermsOfServiceSelected: Bool = true
    @State private var agreeToReceiveAdvertisingInformationSelected: Bool = true
    @State private var consentToMarketingUtilizationSelected: Bool = true
    
    private let terms: [TermType] = TermType.allCases
    private var didAgreedToMandatoryConsent: Bool {
        ageLimitSelected && agreeToTermsOfServiceSelected
    }
    
    var body: some View {
        BasedFormView("어디 이용을 위한\n약관을 동의해주세요") {
            VStack(spacing: 20) {
                HStack {
                    CircleSelectionButton($isAllSelected)
                        .onChange(of: isAllSelected) {
                            guard $1 else { return }
                            ageLimitSelected = $1
                            agreeToTermsOfServiceSelected = $1
                            agreeToReceiveAdvertisingInformationSelected = $1
                            consentToMarketingUtilizationSelected = $1
                        }
                    
                    Text("네, 모두 동의합니다.")
                        .whereFont(.body16medium)
                        .foregroundStyle(Color(hex: 0x6366F1))
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.clear)
                        .strokeBorder(Color(hex: 0x6366F1))
                )
                .padding(.top)
                
                ForEach(terms, id: \.self) { term in
                    termCell(term)
                }
            }
            .padding(.top)
        } footer: {
            Button {
                // TODO: 이메일 제출, 인증 화면으로 이동
            } label: {
                Text("다음")
                    .whereFont(.body16semibold)
            }
            .buttonStyle(.whereRoundedProminent(didAgreedToMandatoryConsent == false))
        }
    }
    
    @ViewBuilder private func termCell(_ type: TermType) -> some View {
        HStack {
            CircleSelectionButton(bindSelection(type))
                .onChange(of: bindSelection(type).wrappedValue) { _, _ in
                    updateAllSelection()
                }
            
            Text(type.title)
                .whereFont(.body16regular)
                .foregroundStyle(Color(hex: 0x656C73))
            
            Spacer()
            
            Button {
                // TODO: 약관 표시 방식? 노션으로 이동? 물어보기
            } label: {
                Text("보기")
                    .whereFont(.caption12regular)
                    .foregroundStyle(Color(hex: 0x747474))
                    .frame(width: 42, height: 26)
                    .padding(3)
                    .background(Color(hex: 0xEEEFEF))
                    .clipShape(.capsule)
            }
        }
    }
    
    private func bindSelection(_ type: TermType) -> Binding<Bool> {
        switch type {
        case .ageLimit:
            return Binding(
                get: { ageLimitSelected },
                set: { ageLimitSelected = $0 }
            )
        case .agreeToTermsOfService:
            return Binding(
                get: { agreeToTermsOfServiceSelected },
                set: { agreeToTermsOfServiceSelected = $0 }
            )
        case .agreeToReceiveAdvertisingInformation:
            return Binding(
                get: { agreeToReceiveAdvertisingInformationSelected },
                set: { agreeToReceiveAdvertisingInformationSelected = $0 }
            )
        case .consentToMarketingUtilization:
            return Binding(
                get: { consentToMarketingUtilizationSelected },
                set: { consentToMarketingUtilizationSelected = $0 }
            )
        }
    }
    
    private func updateAllSelection() {
        // 각각의 동의 항목이 모두 선택 되었을 경우 전체 동의 버튼도 선택
        isAllSelected = ageLimitSelected &&
                        agreeToTermsOfServiceSelected &&
                        agreeToReceiveAdvertisingInformationSelected &&
                        consentToMarketingUtilizationSelected
    }
}

// MARK: Nested Types
extension RegistrationTermView {
    enum TermType: CaseIterable, Hashable {
        /// 연령 제한 (14세 이상)
        case ageLimit
        /// 서비스 이용약관 동의
        case agreeToTermsOfService
        /// 광고성 정보 수신 동의
        case agreeToReceiveAdvertisingInformation
        /// 마케팅 활용 동의
        case consentToMarketingUtilization
        
        var title: String {
            switch self {
            case .ageLimit:
                return "[필수] 만 14세 이상입니다."
            case .agreeToTermsOfService:
                return "[필수] 어디 서비스 이용약관 동의"
            case .agreeToReceiveAdvertisingInformation:
                return "[선택] 광고성 정보 수신 동의"
            case .consentToMarketingUtilization:
                return "[선택] 마케팅 활용 동의"
            }
        }
    }
    
    struct CircleSelectionButton: View {
        @Binding var isSelected: Bool
        
        init(_ isSelected: Binding<Bool>) {
            self._isSelected = isSelected
        }
        
        var body: some View {
            Button {
                isSelected.toggle()
            } label: {
                Image(.whereCheckmark)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(3)
                    .background(isSelected ? .accent : Color(hex: 0xCED4DA))
                    .clipShape(.circle)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegistrationTermView()
    }
}
