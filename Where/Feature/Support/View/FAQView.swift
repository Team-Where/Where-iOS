//
//  FAQView.swift
//  Where
//
//  Created by Swain Yun on 3/21/25.
//

import SwiftUI
import Swinject

struct FAQView: View {
    @State private var navigationType: NavigationType?
    @State private var announcements: [Announcement] = []
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 20) {
                    ForEach(announcements) { announcement in
                        Cell(announcement)
                            .listRowSeparator(.hidden)
                    }
                }
            }
            
            Button {
                navigationType = .editInquiry
            } label: {
                Text("1:1 문의하기")
                    .whereFont(.body16medium)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.whereRoundedProminent())
            .padding(.horizontal)
        }
        .navigationDestination(item: $navigationType) { type in
            // TODO: 화면 연결 필요
            switch type {
            case .editAnnouncement:
                EmptyView()
            case .editInquiry:
                InquiryView(resolver: resolver)
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
                Text("FAQ")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
            
            // MARK: 관리자 권한인지 판단해서 노출할 수 있도록 수정해야함
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    navigationType = .editAnnouncement
                } label: {
                    Image(systemName: "pencil.line")
                        .foregroundStyle(.where(.gray800))
                }
            }
        }
    }
}

// MARK: Nested Types
extension FAQView {
    struct Cell: View {
        @State private var isExpanded: Bool = false
        
        let announcement: Announcement
        
        init(_ announcement: Announcement) {
            self.announcement = announcement
        }
        
        var body: some View {
            DisclosureGroup(isExpanded: $isExpanded) {
                Text(announcement.content)
            } label: {
                HStack(spacing: 10) {
                    Text("Q")
                        .foregroundStyle(.accent)
                    
                    Text(announcement.title)
                        .foregroundStyle(.where(.gray800))
                }
                .whereFont(.body16semibold)
            }
            .disclosureGroupStyle(WhereDisclosureGroupStyle(labelHeight: 60))
        }
    }
}

// MARK: NavigationType
extension FAQView {
    /// 모임정보 상세 화면에서 라우팅 가능한 네비게이션패스의 종류
    enum NavigationType: Hashable {
        /// FAQ 및 공지사항 작성 화면
        case editAnnouncement
        /// 1:1 문의 작성 화면
        case editInquiry
    }
}
