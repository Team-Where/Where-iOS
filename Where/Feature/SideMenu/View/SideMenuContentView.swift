//
//  SideMenuContentView.swift
//  Where
//
//  Created by 이현호 on 2/8/25.
//

import SwiftUI
import Swinject

struct SideMenuContentView: View {
    @Binding var isSideMenuPresented: Bool // 사이드 메뉴 상태
    @ObservedObject private var viewModel: SideMenuContentViewModel
    @State private var navigationType: NavigationType?
    
    private let resolver: Resolver
    
    init(
        _ isSideMenuPresented: Binding<Bool>,
        resolver: Resolver
    ) {
        self._isSideMenuPresented = isSideMenuPresented
        self.viewModel = resolver.resolve(SideMenuContentViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            profileSection()
            
            if viewModel.user != nil {
                meetingSummarySection()
            }

            // 구분선
            VStack {
                Rectangle()
                    .foregroundStyle(Color(hex: 0xF1F3F5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 8)
                    .padding(.top, 31)
                    .padding(.bottom, 40)
            }
            
            // 메뉴 리스트
            VStack(alignment: .leading, spacing: 32) {
                SideMenuItem($navigationType, type: .settings, title: "설정", iconName: "gear")
                SideMenuItem($navigationType, type: .notifications, title: "알림", iconName: "bell")
                SideMenuItem($navigationType, type: .FAQs, title: "FAQ", iconName: "bubble")
                SideMenuItem($navigationType, type: .inquiries, title: "1:1 문의", iconName: "square.and.pencil")
                SideMenuItem($navigationType, type: .announcements, title: "공지사항", iconName: "megaphone")
            }
            .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationDestination(item: $navigationType) { type in
            switch type {
            case .settings: PreferenceView()
            case .notifications: NotificationListView()
            case .FAQs: FAQView(resolver: resolver)
            case .inquiries: InquiryView(resolver: resolver)
            case .announcements: AnnouncementView()
            case .editProfile: EditProfileView(resolver: resolver)
            }
        }
        .fullScreenCover(isPresented: $viewModel.isLoginViewPresented) {
            LoginView($viewModel.isLoginViewPresented, resolver: resolver)
        }
    }
    
    @ViewBuilder private func profileSection() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.user?.nickname ?? "로그인 해주세요")
                    .whereFont(.title24semibold)
                
                Button {
                    if viewModel.isLoginNeeded {
                        viewModel.login()
                    } else {
                        navigationType = .editProfile
                    }
                } label: {
                    if viewModel.isLoginNeeded {
                        Text("로그인")
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil.line")
                            
                            Text("프로필 수정")
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .whereFont(.body14medium)
                .foregroundStyle(Color(hex: 0x4F46E5))
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(.white)
                        .strokeBorder(.where(hex: 0xDEE2E6))
                )
            }
            
            Spacer()
            
            Image("DefaultProfile")
                .resizable()
                .frame(width: 80, height: 80)
        }
        .padding(.top, 40)
        .padding(.horizontal)
    }
    
    @ViewBuilder private func meetingSummarySection() -> some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                
                Text("총 모임 횟수")
            }
            .whereFont(.body16medium)
            .foregroundStyle(.where(.gray800))
            
            Spacer()
            
            Text("\(viewModel.totalMeetingsCount)")
                .whereFont(.body16semibold)
                .foregroundStyle(.accent)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.where(hex: 0xEEF2FF))
        )
        .padding(.top, 40)
        .padding(.horizontal)
    }
}

// MARK: Nested Types
extension SideMenuContentView {
    // 사이드 메뉴 아이템
    struct SideMenuItem: View {
        @Binding var selectedNavigationType: NavigationType?
        let type: NavigationType
        let title: String
        let iconName: String
        
        init(
            _ selected: Binding<NavigationType?>,
            type: NavigationType,
            title: String,
            iconName: String
        ) {
            self._selectedNavigationType = selected
            self.type = type
            self.title = title
            self.iconName = iconName
        }

        var body: some View {
            Button {
                selectedNavigationType = type
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: iconName)
                        .foregroundStyle(.black)
                        .frame(width: 18, height: 18)
                    
                    Text(title)
                        .whereFont(.body16regular)
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 4, height: 8)
                        .foregroundStyle(.where(.gray600))
                }
                .whereFont(.subtitle18semibold)
                .foregroundStyle(.where(.gray900))
            }
        }
    }
    
    /// SideMenuContentView 화면에서 라우팅할 수 있는 NavigationPath의 종류
    enum NavigationType {
        /// 설정
        case settings
        /// 알림 목록
        case notifications
        /// FAQ
        case FAQs
        /// 1:1 문의
        case inquiries
        /// 공지사항
        case announcements
        /// 프로필 수정
        case editProfile
    }
}

#Preview {
    NavigationStack {
        SideMenuContentView(.constant(true), resolver: PreviewHelper.shared.resolver)
    }
}
