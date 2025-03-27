//
//  HowToAddMeetingView.swift
//  Where
//
//  Created by Swain Yun on 3/24/25.
//

import SwiftUI

struct HowToAddMeetingView: View {
    private let steps: [GuideStep] = GuideStep.allCases
    
    var body: some View {
        List {
            ForEach(steps, id: \.id) { step in
                section(step)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.never)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("모임 추가 방법")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
        }
    }
    
    @ViewBuilder private func section(_ step: GuideStep) -> some View {
        Section {
            step.image
                .resizable()
                .scaledToFit()
        } header: {
            HStack(spacing: 8) {
                Text("\(step.id)")
                    .whereFont(.body14medium)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(.accent)
                    )
                
                Text(step.title)
                    .whereFont(.body14medium)
                    .foregroundStyle(.where(.gray900))
                
                Spacer()
            }
        }
    }
}

// MARK: Nested Types
extension HowToAddMeetingView {
    /// 단계별 모임 추가 방법 안내
    enum GuideStep: Int, CaseIterable {
        /// 모임 등록
        case registerForMeeting = 1
        /// 친구 초대
        case inviteFriends
        /// 장소 공유
        case shareLocation
        
        var id: Int { self.rawValue }
        
        var title: String {
            switch self {
            case .registerForMeeting: "추가하고 싶은 모임을 등록해보세요."
            case .inviteFriends: "모임 참석할 친구를 초대해보세요."
            case .shareLocation: "모임 장소를 참석하는 친구들과 함께 공유해보세요."
            }
        }
        
        var image: Image {
            switch self {
            case .registerForMeeting: Image(.guide1)
            case .inviteFriends: Image(.guide2)
            case .shareLocation: Image(.guide3)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HowToAddMeetingView()
    }
}
