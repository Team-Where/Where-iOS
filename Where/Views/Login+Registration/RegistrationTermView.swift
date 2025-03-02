//
//  RegistrationTermView.swift
//  Where
//
//  Created by Swain Yun on 12/31/24.
//

import SwiftUI

struct RegistrationTermView: View {
    @State private var termSelections: [TermType: Bool] = TermType.allCases.reduce(into: [:]) {
        $0[$1] = true
    }
    
    @State private var isAllSelectedState: Bool = true
    
    private let terms: [TermType] = TermType.allCases
    private var didAgreedToMandatoryConsent: Bool {
        termSelections[.ageLimit] == true && termSelections[.agreeToTermsOfService] == true
    }
    
    private let navigationTitle: String = "어디 이용을 위한\n약관을 동의해주세요"
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                CircleSelectionButton($isAllSelectedState) {
                    isAllSelectedState ? selectAllTerms() : deselectAllTerms()
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
        .whereForm(navigationTitle) {
            NavigationLink {
                AuthentificationView()
            } label: {
                Text("다음")
                    .whereFont(.body16semibold)
                    .frame(width: 350, height: 48)
            }
            .buttonStyle(.whereRoundedProminent(didAgreedToMandatoryConsent == false))
        }
    }
    
    @ViewBuilder private func termCell(_ type: TermType) -> some View {
        HStack {
            CircleSelectionButton(bindSelection(type))
                .onChange(of: bindSelection(type).wrappedValue) { _, _ in
                    updateAllSelectionState()
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
        Binding(
            get: { termSelections[type] ?? false },
            set: { termSelections[type] = $0 }
        )
    }
    
    private func updateAllSelectionState() {
        isAllSelectedState = termSelections.values.allSatisfy { $0 }
    }
    
    private func selectAllTerms() {
        TermType.allCases.forEach { termSelections[$0] = true }
    }
    
    private func deselectAllTerms() {
        TermType.allCases.forEach { termSelections[$0] = false }
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
        let action: (() -> Void)?
        
        init(
            _ isSelected: Binding<Bool>,
            action: (() -> Void)? = nil
        ) {
            self._isSelected = isSelected
            self.action = action
        }
        
        var body: some View {
            Button {
                isSelected.toggle()
                action?()
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
