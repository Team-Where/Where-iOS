//
//  OnboardingView.swift
//  Where
//
//  Created by Swain Yun on 12/29/24.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppStorageKey.isOnboardingNeeded) private var isOnboardingNeeded: Bool = true
    @State private var currentStepIndex: Int = .zero
    
    private let steps: [OnboardingStep] = OnboardingStep.allCases
    private var title: String { steps[currentStepIndex].title }
    
    var body: some View {
        BasedFormView(header: Text(title)) {
            TabView(selection: $currentStepIndex) {
                ForEach(steps.indices, id: \.self) { index in
                    steps[index].image
                        .tag(index)
                }
            }
            .disabled(true) // 건너뛰기 버튼을 통해서만 단계 이동
            .tabViewStyle(.page(indexDisplayMode: .never))
            .overlay(alignment: .bottom) {
                PageControl(currentPageIndex: $currentStepIndex, pageCountLimit: steps.count)
                    .alignmentGuide(.bottom) { dimension in
                        dimension.height * 6
                    }
            }
        } footer: {
            if currentStepIndex == steps.count - 1 {
                completeOnboardingButton
            } else {
                skipToNextStepButton
            }
        }
    }
    
    private var skipToNextStepButton: some View {
        Button {
            withAnimation {
                currentStepIndex += 1
            }
        } label: {
            Text("건너뛰기")
                .whereFont(.body16medium)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        }
    }
    
    private var completeOnboardingButton: some View {
        Button {
            isOnboardingNeeded = false
            dismiss()
        } label: {
            Text("시작")
                .whereFont(.body16semibold)
                .padding(10)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: Nested Types
extension OnboardingView {
    enum OnboardingStep: CaseIterable {
        // 온보딩 1: 모임을 정할 수 있어요!
        case meetingSelection
        // 온보딩 2: 원하는 장소를 확인해요
        case checkPlace
        // 온보딩 3: 위치까지 체크할 수 있어요
        case checkLocation
        
        var title: String {
            switch self {
            case .meetingSelection:
                return "친구들과 한 공간에서\n모임을 정할 수 있어요!"
            case .checkPlace:
                return "다른 친구들과\n원하는 장소를 확인해요"
            case .checkLocation:
                return "장소를 결정하고\n위치까지 체크할 수 있어요"
            }
        }
        
        var image: Image {
            switch self {
            case .meetingSelection:
                return Image(.onboardingCharacter1)
            case .checkPlace:
                return Image(.onboardingCharacter2)
            case .checkLocation:
                return Image(.onboardingCharacter3)
            }
        }
    }
    
    struct PageControl: View {
        @Binding var currentPageIndex: Int
        let pageCountLimit: Int
        
        init(currentPageIndex: Binding<Int>, pageCountLimit: Int) {
            self._currentPageIndex = currentPageIndex
            self.pageCountLimit = pageCountLimit
        }
        
        var body: some View {
            HStack {
                ForEach(0..<pageCountLimit, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(currentPageIndex == index ? .accent : Color(hex: 0xD1D5DB))
                        .frame(maxWidth: index == currentPageIndex ? 26 : 8, maxHeight: 8)
                }
            }
            .padding(8)
            .clipShape(.capsule)
            .animation(.easeInOut, value: currentPageIndex)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
}
