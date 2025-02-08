//
//  TabBarView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0 // 현재 선택된 탭의 인덱스
    @State private var showNewMeeting = false // sheet 표시 여부
    @State private var previousTab = 0 // 이전 탭 저장
    @State private var isSideMenu: Bool = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // 내모임 뷰
                HomeView(isSideMenu: $isSideMenu)
                    .tabItem {
                        Label("내모임", systemImage: "person.2")
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
                FriendsListView()
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
                    showNewMeeting = true
                    selectedTab = previousTab
                }
            }
            .sheet(isPresented: $showNewMeeting) {
                NewMeetingSheet1View(showNewMeeting: $showNewMeeting)
                    .presentationCornerRadius(24)
            }
            VStack {
                Spacer()
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .foregroundColor(Color(hex: 0xE5E7EB))
                    .padding(.bottom, 60)
            }
            // 사이드메뉴 추가
            ZStack {
                // 배경 탭하면 사이드메뉴 닫힘
                Color.black.opacity(isSideMenu ? 0.3 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSideMenu = false
                        }
                    }
                
                // 사이드메뉴 뷰
                SideMenuView($isSideMenu, width: 370) {
                    VStack {
                        SideMenuContentView(isSideMenu: $isSideMenu)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .offset(x: isSideMenu ? 0 : 370) // 오른쪽에서 왼쪽으로 생성
                .animation(.easeInOut(duration: 0.3), value: isSideMenu)
            }
            .ignoresSafeArea(edges: .all)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    TabBarView()
}
