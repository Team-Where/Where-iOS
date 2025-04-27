//
//  ContentView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI
import Swinject

struct ContentView: View {
    @State private var selectedTab: TabItem = .myMeeting
    @State private var previousTab: TabItem = .myMeeting
    @State private var isCreateMeetingSheetPresented = false // sheet 표시 여부
    @State private var isCompleteCreationViewPresented = false
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 내모임 뷰
            NavigationStack {
                MyMeetingView(resolver: resolver)
            }
            .tabItem {
                Label("내 모임", systemImage: "person.2")
                    .environment(\.symbolVariants, .none)
            }
            .tag(TabItem.myMeeting)
            
            // 새 모임 만들기
            Color.clear
                .tabItem {
                    Image("BottomPlus")
                }
                .tag(TabItem.createMeeting)
            
            // 친구목록 뷰
            NavigationStack {
                FriendsListView(resolver: resolver)
            }
            .tabItem {
                Label("친구목록", systemImage: "list.bullet")
            }
            .tag(TabItem.friendsList)
        }
        .tint(.black) // 선택된 탭 아이템의 색상
        .onChange(of: selectedTab) { _, newValue in
            guard newValue == .createMeeting else {
                return previousTab = newValue
            }
            isCreateMeetingSheetPresented = true
            selectedTab = previousTab
        }
        .sheet(isPresented: $isCreateMeetingSheetPresented) {
            CreateMeetingView(resolver: resolver)
                .presentationCornerRadius(24)
                .presentationDetents([.fraction(0.99)])
        }
        .fullScreenCover(isPresented: $isCompleteCreationViewPresented) {
            // TODO: 미팅 생성 성공 후, 미팅 인스턴스 넘기는 처리 구현
//            CompleteCreationView(isCompleteCreationViewPresented: $isCompleteCreationViewPresented, meeting: <#Meeting#>)
        }
    }
}

// MARK: Nested Types
extension ContentView {
    enum TabItem: Hashable {
        case myMeeting
        case createMeeting
        case friendsList
    }
}

#Preview {
    NavigationStack {
        ContentView(resolver: PreviewHelper.shared.resolver)
    }
}
