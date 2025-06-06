//
//  NotificationListView.swift
//  Where
//
//  Created by Swain Yun on 3/21/25.
//

import SwiftUI
import Swinject

struct NotificationListView: View {
    private let viewModel: NotificationListViewModel
    
    init(resolver: Resolver) {
        self.viewModel = resolver.resolve(NotificationListViewModel.self)!
    }
    
    var body: some View {
        VStack {
            if viewModel.notifications.isEmpty {
                unavailableView()
            } else {
                notificationsSection()
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
            ForEach(viewModel.notifications) { notification in
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
            
            Text(notification.date.relativeTimeDisplay())
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
