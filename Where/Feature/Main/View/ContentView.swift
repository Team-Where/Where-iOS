//
//  ContentView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI
import Swinject

fileprivate typealias TabItem = TabViewSelection.TabItem

struct ContentView: View {
    @AppStorage(AppStorageKey.isOnboardingNeeded) private var isOnboardingNeeded: Bool = true
    @StateObject private var tabViewSelection = TabViewSelection()
    @State private var fullScreenCoverType: MainFullScreenCoverType?
    @State private var sheetType: MainSheetType?
    @State private var isLoginNeededPopupPresented: Bool = false
    @State private var isRegistrationNeeded: Bool = false
    @State private var isLoginNeeded: Bool = false
    
    private let viewModel: ContentViewModel
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.viewModel = resolver.resolve(ContentViewModel.self)!
    }
    
    var body: some View {
        TabView(selection: $tabViewSelection.selectedTab) {
            // 내모임 뷰
            MyMeetingView(resolver: resolver) { fullScreenCoverType = .login }
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
            FriendsListView(resolver: resolver)
                .tabItem {
                    Label("친구목록", systemImage: "list.bullet")
                }
                .tag(TabItem.friendsList)
        }
        .tint(.black) // 선택된 탭 아이템의 색상
        .onChange(of: tabViewSelection.selectedTab, onTabSelectionChange)
        .onChange(of: viewModel.isLoginNeeded, onLoginStateChange)
        .onChange(of: viewModel.isRegistrationNeeded, onRegistrationStateChange)
        .onChange(of: isLoginNeeded) { _, isNeeded in
            guard isNeeded else { return }
            fullScreenCoverType = .login
        }
        .sheet(item: $sheetType) { type in
            switch type {
            case .createMeeting:
                CreateMeetingView(resolver: resolver, sheetType: $sheetType, fullScreenCoverType: $fullScreenCoverType)
            }
        }
        .fullScreenCover(item: $fullScreenCoverType) { type in
            switch type {
            case .completeCreation(let meeting):
                CompleteCreationView(meeting: meeting)
            case .login:
                LoginView(resolver: resolver)
            }
        }
        .navigationDestination(isPresented: $isRegistrationNeeded) {
            ProfileCreationView($isRegistrationNeeded, resolver: resolver)
        }
        .navigationDestination(isPresented: $isOnboardingNeeded) {
            OnboardingView()
        }
        .popup($isLoginNeededPopupPresented) {
            VStack(spacing: 22) {
                Text("로그인 후 모임을 만들 수 있어요.")
                    .whereFont(.body14medium)
                    .foregroundStyle(Color(hex: 0x343A40))
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 10) {
                    Button {
                        withAnimation {
                            isLoginNeededPopupPresented = false
                        }
                    } label: {
                        Text("다음에")
                            .whereFont(.body16semibold)
                            .foregroundStyle(.where(hex: 0x4B5563))
                            .padding(10)
                    }
                    .buttonStyle(.whereRoundedProminent(background: .where(.gray100)))
                    
                    Button {
                        withAnimation {
                            isLoginNeededPopupPresented = false
                            fullScreenCoverType = .login
                        }
                    } label: {
                        Text("로그인하기")
                            .whereFont(.body16semibold)
                            .padding(10)
                    }
                    .buttonStyle(.whereRoundedProminent())
                }
            }
            .padding()
        }
    }
}

// MARK: - Nested Types
//extension ContentView {
    /// 메인(루트) 화면에서 라우팅 가능한 풀스크린커버의 종류
    enum MainFullScreenCoverType: Identifiable {
        /// 모임 생성 완료 화면
        case completeCreation(Meeting)
        /// 로그인 화면
        case login
        
        var id: String { String(describing: self) }
    }
    
    /// 메인(루트) 화면에서 라우팅 가능한 시트의 종류
    enum MainSheetType: Identifiable {
        /// 모임 생성 화면
        case createMeeting
        
        var id: String { String(describing: self) }
    }
//}

// MARK: - Methods
private extension ContentView {
    func onTabSelectionChange(_ previous: TabItem, _ current: TabItem) {
        guard case .createMeeting = current else { return tabViewSelection.selectTab(current) }
        tabViewSelection.selectTab(previous)
        
        // 새 모임 만들기 탭이 선택 됐을 때,
        // 로그인 상황이라면 새 모임 만들기 화면 등장
        guard viewModel.isLoginNeeded else { return sheetType = .createMeeting }
        
        // 비로그인 상황이라면 로그인 안내 팝업 등장
        isLoginNeededPopupPresented = true
    }
    
    func onLoginStateChange(_ : Bool, isLoginNeeded: Bool) {
        guard isLoginNeeded else {
            if case .login = fullScreenCoverType { fullScreenCoverType = nil }
            return
        }
        fullScreenCoverType = .login
    }
    
    func onRegistrationStateChange(_ : Bool, isRegistrationNeeded: Bool) {
        guard isRegistrationNeeded else { return }
        let work = DispatchWorkItem { self.isRegistrationNeeded = isRegistrationNeeded }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
    }
    
    func onMeetingCreated(_ meeting: Meeting) {
        fullScreenCoverType = .completeCreation(meeting)
    }
}

#Preview {
    ContentView(resolver: PreviewHelper.shared.resolver)
}
