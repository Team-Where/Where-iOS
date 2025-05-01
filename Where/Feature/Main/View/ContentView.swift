//
//  ContentView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI
import Swinject

fileprivate typealias TabItem = ContentViewModel.TabItem

struct ContentView: View {
    @ObservedObject private var viewModel: ContentViewModel
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.viewModel = resolver.resolve(ContentViewModel.self)!
    }
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
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
        .onChange(of: viewModel.selectedTab) { _, newTab in
            viewModel.onChange(newTab)
        }
        .sheet(isPresented: $viewModel.isCreateMeetingSheetPresented) {
            CreateMeetingView(resolver: resolver)
                .presentationCornerRadius(24)
                .presentationDetents([.fraction(0.99)])
        }
        .fullScreenCover(item: $viewModel.fullScreenCoverType) { type in
            switch type {
            case .completeCreation(let meeting):
                CompleteCreationView(meeting: meeting)
            case .login:
                LoginView(resolver: resolver, viewModel.willFullScreenCoverDisappear)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView(resolver: PreviewHelper.shared.resolver)
    }
}
