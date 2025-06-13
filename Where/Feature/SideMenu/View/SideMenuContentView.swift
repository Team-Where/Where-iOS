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
    
    private let user: User?
    private let meetingsCount: Int
    private let resolver: Resolver
    private let onLoginButtonTapped: () -> Void
    
    private var isLoginNeeded: Bool { user == nil }
    
    init(
        _ isSideMenuPresented: Binding<Bool>,
        user: User?,
        meetingsCount: Int,
        resolver: Resolver,
        onLoginButtonTapped: @escaping () -> Void
    ) {
        self._isSideMenuPresented = isSideMenuPresented
        self.user = user
        self.meetingsCount = meetingsCount
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
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(user?.nickname ?? "로그인 해주세요")
                            .whereFont(.title24semibold)
                        
                        Group {
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
                
                Group {
                    if isLoginNeeded {
                        EmptyView()
                    } else {
                        HStack {
                            HStack(spacing: 10) {
                                Image(systemName: "calendar")
                                
                                Text("총 모임 횟수")
                            }
                            .whereFont(.body16medium)
                            .foregroundStyle(.where(.gray800))
                            
                            Spacer()
                            
                            Text("\(meetingsCount)")
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
                        .transition(.move(edge: .trailing))
                    }
                }
            }
            .animation(.easeInOut, value: isSideMenuPresented)
            
            // 구분선
            Rectangle()
                .foregroundStyle(Color(hex: 0xF1F3F5))
                .frame(maxWidth: .infinity)
                .frame(height: 8)
                .padding(.top, 31)
                .padding(.bottom, 40)
            
            // 메뉴 리스트
            LazyVStack(alignment: .leading, spacing: 32) {
                SideMenuCell(type: .notifications, resolver: resolver)
                SideMenuCell(type: .FAQs, resolver: resolver)
                SideMenuCell(type: .inquiries, resolver: resolver)
                SideMenuCell(type: .announcements, resolver: resolver)
                SideMenuCell(type: .settings(user), resolver: resolver)
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}

// MARK: - Subviews
private extension SideMenuContentView {
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
                case .settings(let user): PreferenceView(user: user, resolver: resolver)
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
    enum SideMenuType: Identifiable {
        /// 알림 목록
        case notifications
        /// FAQ
        case FAQs
        /// 1:1 문의
        case inquiries
        /// 공지사항
        case announcements
        /// 설정
        case settings(User?)
        
        var id: String { String(describing: self) }
        
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
