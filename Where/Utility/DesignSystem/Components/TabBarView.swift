//
//  TabBarView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI
import Swinject

struct TabBarView: View {
    @State private var selectedTab = 0 // 현재 선택된 탭의 인덱스
    @State private var isCreateMeetingSheetPresented = false // sheet 표시 여부
    @State private var previousTab = 0 // 이전 탭 저장
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 내모임 뷰
            HomeView($selectedTab, $isCreateMeetingSheetPresented, resolver: resolver)
                .overlay(alignment: .bottom) {
                    Divider()
                }
                .tabItem {
                    Label("내 모임", systemImage: "person.2")
                        .environment(\.symbolVariants, .none)
                }
                .tag(0)
            
            // 새 모임 만들기
            Color.clear
                .tabItem {
                    Image("BottomPlus")
                }
                .tag(1)
            
            // 친구목록 뷰
            FriendsListView(selected: $selectedTab, resolver: resolver)
                .overlay(alignment: .bottom) {
                    Divider()
                }
                .tabItem {
                    Label("친구목록", systemImage: "list.bullet")
                }
                .tag(2)
        }
        .tint(.black) // 선택된 탭 아이템의 색상
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue != 1 {
                previousTab = newValue
            } else {
                isCreateMeetingSheetPresented = true
                selectedTab = previousTab
            }
        }
    }
}

#Preview {
    NavigationStack {
        TabBarView(resolver: PreviewHelper.shared.resolver)
    }
}
