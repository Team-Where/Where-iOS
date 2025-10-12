//
//  AnnouncementView.swift
//  Where
//
//  Created by Swain Yun on 3/22/25.
//

import SwiftUI
import Swinject

struct AnnouncementView: View {
    @State private var navigationType: NavigationType?
    @State private var viewModel: AnnouncementViewModel
    
    init(resolver: Resolver) {
        self.viewModel = resolver.resolve(AnnouncementViewModel.self)!
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(viewModel.announcements) { announcement in
                    Cell(announcement)
                }
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
                Text("공지사항")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
        }
    }
}

// MARK: Nested Type
extension AnnouncementView {
    /// 공지사항 화면에서 라우팅 가능한 네비게이션패스의 종류
    enum NavigationType: Hashable {
        /// FAQ 및 공지사항 작성 화면
        case editAnnouncement
    }
}

// MARK: - Subviews
extension AnnouncementView {
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
                VStack(alignment: .leading, spacing: 6) {
                    Text(announcement.title)
                        .whereFont(.body16medium)
                        .foregroundStyle(.where(.gray800))
                    
                    DateView(date: announcement.date, format: .yyyyMMdd, prompt: String())
                        .whereFont(.body14regular)
                        .foregroundStyle(.where(.gray700))
                }
            }
            .disclosureGroupStyle(WhereDisclosureGroupStyle(labelHeight: 74))
        }
    }
}
