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
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // 내모임 뷰
                HomeView()
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
                Text("친구목록 뷰")
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
        }
        .navigationBarBackButtonHidden()
    }
}


#Preview {
    TabBarView()
}
