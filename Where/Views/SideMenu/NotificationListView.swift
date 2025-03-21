//
//  NotificationListView.swift
//  Where
//
//  Created by Swain Yun on 3/21/25.
//

import SwiftUI

struct NotificationListView: View {
    @State private var notifications: [Notification] = [
//        .init(id: 0, title: "친구 추가", content: "냠냠쩝쩝님이 또구몬님을 친구로 추가하셨어요.", type: .notification),
//        .init(id: 1, title: "오늘의 모임", content: "오늘 또구몬님의 모임이 있어요!", type: .notification),
//        .init(id: 2, title: "모임 초대", content: "또구몬님이 냠냠쩝쩝님의 모임에 초대되었어요.", type: .notification),
//        .init(id: 3, title: "공지", content: "[이벤트] 신규가입 이벤트 당첨자가 발표되었어요.", type: .notification),
//        .init(id: 4, title: "답변 완료", content: "1:1 답변 등록이 완료되었습니다.", type: .QandA),
//        .init(id: 5, title: "모임 안내문", content: "모임을 추가하는 방법을 FAQ에서 알아보세요!", type: .notification)
    ]
    
    var body: some View {
        VStack {
            if notifications.isEmpty {
                unavailableView()
            } else {
                notificationsSection()
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
        }
    }
    
    @ViewBuilder private func unavailableView() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle")
                .foregroundStyle(.where(.gray600))
            
            Text("새로운 알림이 없어요!")
                .whereFont(.body16medium)
                .foregroundStyle(.where(.gray700))
        }
    }
    
    @ViewBuilder private func notificationsSection() -> some View {
        List {
            ForEach(notifications) { notification in
                notificationCell(notification)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .padding(.top)
    }
    
    @ViewBuilder private func notificationCell(_ notification: Notification) -> some View {
        HStack(alignment: .top) {
            ZStack {
                Circle()
                    .foregroundStyle(.accent.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(.logoColorShort)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(notification.title)
                    .whereFont(.body16medium)
                    .foregroundStyle(.where(.gray800))
                    .overlay(alignment: .topTrailing) {
                        Badge()
                            .alignmentGuide(.top) { dimension in
                                dimension.height / 4
                            }
                            .alignmentGuide(.trailing) { dimension in
                                dimension.width - 10
                            }
                    }
                
                Text(notification.content)
                    .whereFont(.body14regular)
                    .foregroundStyle(.where(.gray600))
            }
            
            Spacer()
            
            // TODO: 수신시각 확인할 수 있도록 Notification 모델 수정 필요
            Text("지금")
                .whereFont(.caption12regular)
                .foregroundStyle(.where(.gray600))
        }
        .padding(.top)
    }
}

extension NotificationListView {
    struct Badge: View {
        var body: some View {
            Circle()
                .frame(width: 6, height: 6)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationListView()
    }
}
