//
//  MeetingInformationView.swift
//  Where
//
//  Created by Swain Yun on 1/4/25.
//

import SwiftUI

struct MeetingInformationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        SelectionTab(selection: [.meetingInfo, .placeInfo])
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 12)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 6)
                        .foregroundStyle(.black)
                }
            }
            
            ToolbarItem(placement: .principal) {
                // TODO: 모임 도메인 모델 선언 필요
                Text("2024 연말파티")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(Color(hex: 0x1F2937))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(Color(hex: 0x1F2937))
                }
            }
        }
    }
}

// MARK: Nested Types
extension MeetingInformationView {
    /// 모임정보 화면에서 라우팅 가능한 시트의 종류
    enum SheetType {
        /// 모임에서 나가기
        case exitMeeting
    }
    
    enum TabViewItem {
        case meetingInfo
        case placeInfo
        
        var title: String {
            switch self {
            case .meetingInfo: "모임 정보"
            case .placeInfo: "장소"
            }
        }
        
        @ViewBuilder func view() -> some View {
            switch self {
            case .meetingInfo: MeetingInformationDetailView()
            case .placeInfo: ScrollView { Text("hi") }
            }
        }
    }
    
    struct SelectionTab: View {
        @State private var selectedTab: Int = .zero
        
        private let selection: [TabViewItem]
        
        init(selection: [TabViewItem]) {
            self.selection = selection
        }
        
        var body: some View {
            VStack {
                HStack(spacing: 0) {
                    ForEach(selection.indices, id: \.self) { index in
                        tab(index)
                    }
                }
                
                selection[selectedTab].view()
            }
        }
        
        @ViewBuilder private func tab(_ index: Int) -> some View {
            Button {
                selectedTab = index
            } label: {
                let item = selection[index]
                
                VStack {
                    Text(item.title)
                        .whereFont(selectedTab == index ? .body16semibold : .body16regular)
                    
                    Rectangle()
                        .frame(height: 2)
                }
                .foregroundStyle(selectedTab == index ? Color(hex: 0x1F2937) : Color(hex: 0xE5E7EB))
            }
        }
    }
}

#Preview {
    NavigationStack {
        MeetingInformationView()
    }
}
