//
//  WhereTabView.swift
//  Where
//
//  Created by Swain Yun on 1/2/25.
//

import SwiftUI

struct WhereTabView: View {
    @State private var selectedTab: TabViewItem = .myMeeting
    
    var body: some View {
        VStack {
            content()
            
            Spacer()
            
            ZStack {
                HStack {
                    Spacer()
                    
                    tabItem(.myMeeting)
                    
                    Spacer()
                    
                    Image(.addButton)
                    
                    Spacer()
                    
                    tabItem(.friendsList)
                    
                    Spacer()
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
    
    @ViewBuilder private func content() -> some View {
        switch selectedTab {
        case .myMeeting:
            Text("Contents here")
        case .friendsList:
            FriendsListView()
        }
    }
    
    @ViewBuilder private func tabItem(_ item: TabViewItem) -> some View {
        let isSelected = selectedTab == item
        
        Button {
            selectedTab = item
        } label: {
            VStack {
                Image(systemName: item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text(item.title)
            }
            .whereFont(.caption12medium)
            .foregroundStyle(isSelected ? Color(hex: 0x111827) : Color(hex: 0x9CA3AF))
        }
    }
}

// MARK: Nested Types
extension WhereTabView {
    enum TabViewItem {
        case myMeeting, friendsList
        
        var title: String {
            switch self {
            case .myMeeting: "내 모임"
            case .friendsList: "친구목록"
            }
        }
        
        var iconName: String {
            switch self {
            case .myMeeting: "person.2"
            case .friendsList: "list.bullet"
            }
        }
    }
}

#Preview {
    WhereTabView()
}
