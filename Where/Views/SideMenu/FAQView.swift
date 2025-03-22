//
//  FAQView.swift
//  Where
//
//  Created by Swain Yun on 3/21/25.
//

import SwiftUI

struct FAQView: View {
    @State private var navigationType: NavigationType?
    @State private var announcements: [Announcement] = [
        .init(id: 0, title: "어디 서비스가 무엇이죠?", content: "어디는 친구들과 모임을 등록하여 카카오톡 등의 메신저로도 쉽게 공유하여 사용자가 원하는 지도 앱으로도 모임의 위치 혹은 장소를 파악할 수 있는 유용한 모임 공유 서비스입니다.", date: .now, type: .QandA),
        .init(id: 1, title: "닉네임을 변경하고 싶어요.", content: "디엠주세요", date: .now, type: .QandA),
        .init(id: 2, title: "회원탈퇴/로그아웃은 어떻게 하나요?", content: "설정 화면에서 회원탈퇴, 로그아웃 과정을 진행하실 수 있어요. 메뉴를 열어보세요!", date: .now, type: .QandA),
        .init(id: 3, title: "비밀번호를 변경하고 싶어요.", content: "디엠주세요", date: .now, type: .QandA),
        .init(id: 4, title: "모임방은 어떻게 만드나요?", content: "디엠주세요", date: .now, type: .QandA)
    ]
    
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
                    .frame(width: 350, height: 48)
            }
            .buttonStyle(.whereRoundedProminent())
        }
        .navigationDestination(item: $navigationType) { type in
            // TODO: 화면 연결 필요
            switch type {
            case .editAnnouncement:
                EmptyView()
            case .editInquiry:
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    NavigationStack {
        FAQView()
    }
}
