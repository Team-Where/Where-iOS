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
    
    private let viewModel: SideMenuContentViewModel
    private let resolver: Resolver
    private let onLoginButtonTapped: () -> Void
    
    init(
        _ isSideMenuPresented: Binding<Bool>,
        resolver: Resolver,
        onLoginButtonTapped: @escaping () -> Void
    ) {
        self._isSideMenuPresented = isSideMenuPresented
        self.viewModel = resolver.resolve(SideMenuContentViewModel.self)!
        self.resolver = resolver
        self.onLoginButtonTapped = onLoginButtonTapped
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack {
                Spacer()
                
                Button {
                    withAnimation { isSideMenuPresented.toggle() }
                } label: {
                    Image(systemName: "xmark")
                }
                .padding([.top, .trailing])
            }
            .padding(.bottom)
            
            ProfileSection(viewModel.user?.nickname, isLoginNeeded: viewModel.isLoginNeeded, resolver: resolver, onLoginButtonTapped)
            
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
            LazyVStack(alignment: .leading, spacing: 32) {
                ForEach(SideMenuType.allCases) { type in
                    SideMenuCell(type: type, resolver: resolver)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - Subviews
private extension SideMenuContentView {
    struct ProfileSection: View {
        let nickname: String?
        let isLoginNeeded: Bool
        let resolver: Resolver
        let onLoginButtonTapped: () -> Void
        
        init(
            _ nickname: String?,
            isLoginNeeded: Bool,
            resolver: Resolver,
            _ onLoginButtonTapped: @escaping () -> Void
        ) {
            self.nickname = nickname
            self.isLoginNeeded = isLoginNeeded
            self.resolver = resolver
            self.onLoginButtonTapped = onLoginButtonTapped
        }
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text(nickname ?? "로그인 해주세요")
                        .whereFont(.title24semibold)
                    
                    button
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
        
        @ViewBuilder private var button: some View {
            if isLoginNeeded {
                Button {
                    onLoginButtonTapped()
                } label: {
                    Text("로그인")
                }
            } else {
                NavigationLink {
                    EditProfileView(resolver: resolver)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.line")
                        
                        Text("프로필 수정")
                    }
                }
            }
        }
    }
    
    struct SideMenuCell: View {
        let type: SideMenuType
        let resolver: Resolver
        
        var body: some View {
            NavigationLink {
                switch type {
                case .notifications: NotificationListView(resolver: resolver)
                case .FAQs: FAQView(resolver: resolver)
                case .inquiries: InquiryView(resolver: resolver)
                case .announcements: AnnouncementView(resolver: resolver)
                case .settings: PreferenceView(resolver: resolver)
                }
            } label: {
                HStack(spacing: 12) {
                    type.icon
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(.black)
                    
                    Text(type.title)
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
}

// MARK: - Nested Types
extension SideMenuContentView {
    /// SideMenuContentView 화면에서 라우팅할 수 있는 NavigationPath의 종류
    enum SideMenuType: Identifiable, CaseIterable {
        /// 알림 목록
        case notifications
        /// FAQ
        case FAQs
        /// 1:1 문의
        case inquiries
        /// 공지사항
        case announcements
        /// 설정
        case settings
        
        var id: Int { self.hashValue }
        
        var title: String {
            switch self {
            case .notifications: "알림"
            case .FAQs: "FAQ"
            case .inquiries: "1:1 문의"
            case .announcements: "공지사항"
            case .settings: "설정"
            }
        }
        
        var icon: Image {
            switch self {
            case .notifications: Image(.bell)
            case .FAQs: Image(.chat)
            case .inquiries: Image(.users)
            case .announcements: Image(.loudspeaker)
            case .settings: Image(.trailingIcon1)
            }
        }
    }
}

#Preview {
    ContentView(resolver: PreviewHelper.shared.resolver)
}
