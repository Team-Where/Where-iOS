//
//  PreferenceView.swift
//  Where
//
//  Created by Swain Yun on 1/20/25.
//

import SwiftUI
import Swinject

struct PreferenceView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppStorageKey.shouldDisplayNotifications) var shouldDisplayNotifications: Bool = true
    @State private var isPopupPresented: Bool = false
    
    private let user: User?
    private let viewModel: PreferenceViewModel
    private let resolver: Resolver
    
    private var isLoginNeeded: Bool { user == nil }
    
    init(
        user: User?,
        resolver: Resolver
    ) {
        self.user = user
        self.viewModel = resolver.resolve(PreferenceViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                Section {
                    NavigationLink {
                        AdjustPasswordView()
                    } label: {
                        HStack {
                            Text("비밀번호 변경")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 12)
                                .foregroundStyle(Color(hex: 0xADB58D))
                        }
                    }
                    .frame(height: 50)
                    .disabled(isLoginNeeded)
                    
                    Button {
                        withAnimation { isPopupPresented = true }
                    } label: {
                        HStack {
                            Text("로그아웃")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 12)
                                .foregroundStyle(Color(hex: 0xADB58D))
                        }
                    }
                    .frame(height: 50)
                    .disabled(isLoginNeeded)
                    
                    NavigationLink {
                        UnregisterView(resolver: resolver)
                    } label: {
                        HStack {
                            Text("계정 탈퇴")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 12)
                                .foregroundStyle(Color(hex: 0xADB58D))
                        }
                    }
                    .disabled(isLoginNeeded)
                    
                    Toggle(isOn: $shouldDisplayNotifications) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("알림")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Text("어디에서 진행되는 소식과 정보를 알려드려요.")
                                .whereFont(.body14regular)
                                .foregroundStyle(Color(hex: 0x868E96))
                        }
                    }
                    .tint(.accent)
                    .frame(height: 50)
                    
                   

                } header: {
                    HStack {
                        Text("계정 설정")
                            .whereFont(.subtitle18semibold)
                        
                        Spacer()
                    }
                    .frame(height: 45)
                    .background(.white)
                }
                .padding()
                
                Rectangle()
                    .fill(Color(hex: 0xF3F4F6))
                
                Section {
                    Link(destination: LinkType.agreeToPersonalInfoCollection.link!) {
                        HStack {
                            Text("개인정보처리방침")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 12)
                                .foregroundStyle(Color(hex: 0xADB58D))
                        }
                    }
                    .frame(height: 50)
                    
                    Link(destination: LinkType.agreeToTermsOfService.link!) {
                        HStack {
                            Text("서비스 이용약관")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 12)
                                .foregroundStyle(Color(hex: 0xADB58D))
                        }
                    }
                    .frame(height: 50)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("버전 정보")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Text(Bundle.main.appVersion)
                                .whereFont(.body14regular)
                                .foregroundStyle(Color(hex: 0x495057))
                        }
                        
                        Spacer()
                        
                        // TODO: 최신버전 아닐 경우 앱스토어로 이동시키도록 해야함
                        Text(viewModel.versionNotice)
                            .whereFont(.body16regular)
                            .foregroundStyle(Color(hex: 0x495057))
                    }
                    .frame(height: 50)
                } header: {
                    HStack {
                        Text("고객지원")
                            .whereFont(.subtitle18semibold)
                        
                        Spacer()
                    }
                    .frame(height: 45)
                    .background(.white)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("설정")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(Color(hex: 0x1F2937))
            }
        }
        .popup($isPopupPresented) {
            VStack(spacing: 24) {
                Text("정말 로그아웃 하겠습니까?")
                    .whereFont(.body14medium)
                    .foregroundStyle(Color(hex: 0x343A40))
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 8) {
                    Button {
                        withAnimation { isPopupPresented = false }
                    } label: {
                        Text("취소")
                            .whereFont(.body16semibold)
                            .foregroundStyle(.where(hex: 0x4B5563))
                            .padding(10)
                    }
                    .buttonStyle(.whereRoundedProminent(background: .where(.gray100)))
                    
                    Button {
                        viewModel.logout { dismiss() }
                    } label: {
                        Text("로그아웃")
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
extension PreferenceView {
    /// 외부 링크의 종류
    enum LinkType {
        /// 서비스 이용약관 동의
        case agreeToTermsOfService
        /// 개인정보 수집 및 이용 약관 동의
        case agreeToPersonalInfoCollection
        
        var link: URL? {
            switch self {
            case .agreeToTermsOfService:
                URL(string: "https://meteor-condor-9e6.notion.site/20f912bcf29c80e69e6ed03cc42776b5")
            case .agreeToPersonalInfoCollection:
                URL(string: "https://meteor-condor-9e6.notion.site/20f912bcf29c8020a3b6e3c468c30462")
            }
        }
    }
}
