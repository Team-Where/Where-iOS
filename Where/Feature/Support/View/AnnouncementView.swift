//
//  AnnouncementView.swift
//  Where
//
//  Created by Swain Yun on 3/22/25.
//

import SwiftUI

struct AnnouncementView: View {
    @State private var navigationType: NavigationType?
    @State private var announcements: [Announcement] = [
        .init(id: 0, title: "[이벤트] <신규가입 이벤트> 당첨자 발표", content: "안녕하세요 어디 서비스 운영자입니다.\n\n202년 신규가입 이벤트 당첨자를 발표합니다.\n\n<당첨자 발표>\n\n> 냠냠쩝쩝님\n> 이초홍님\n> 진키님\n\n축하드립니다!\n앱을 사용하시면서 불편하신 사항이 있으시다면 어디앱 메뉴에서 [1:1문의]를 이용해주세요.\n감사합니다.", date: .now, type: .common),
        .init(id: 1, title: "[공지] 신규 기능 업데이트 안내", content: "ㅁㄴㅇㄹ", date: .now, type: .common),
        .init(id: 2, title: "[공지] 서버 점검에 따른 서비스 일시 중단 안내", content: "ㄹㅇㄹㅁㄴㅇㄹ", date: .now, type: .common)
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(announcements) { announcement in
                    Cell(announcement)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("공지사항")
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
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: Nested Type
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
                    
                    AsyncDateView(date: .constant(announcement.date), format: .yyyyMMdd, prompt: String())
                        .whereFont(.body14regular)
                        .foregroundStyle(.where(.gray700))
                }
            }
            .disclosureGroupStyle(WhereDisclosureGroupStyle(labelHeight: 74))
        }
    }
}

// MARK: NavigationType
extension AnnouncementView {
    /// 공지사항 화면에서 라우팅 가능한 네비게이션패스의 종류
    enum NavigationType: Hashable {
        /// FAQ 및 공지사항 작성 화면
        case editAnnouncement
    }
}

#Preview {
    NavigationStack {
        AnnouncementView()
    }
}
