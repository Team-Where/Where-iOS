//
//  HistoryReminderView.swift
//  Where
//
//  Created by Swain Yun on 1/3/25.
//

import SwiftUI
import Swinject

fileprivate typealias MonthGroup = HistoryReminderViewModel.MonthGroup
fileprivate typealias YearGroup = HistoryReminderViewModel.YearGroup

struct HistoryReminderView: View {
    @State private var viewModel: HistoryReminderViewModel
    private let user: User
    private let friend: FriendRelationship
    private let resolver: Resolver
    
    init(
        user: User,
        friend: FriendRelationship,
        resolver: Resolver
    ) {
        self.user = user
        self.friend = friend
        self.viewModel = resolver.resolve(HistoryReminderViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        VStack {
            ProfilesArea(user: user, friend: friend)
            
            Rectangle()
                .fill(Color(hex: 0xF3F4F6))
                .frame(height: 8)
            
            Spacer()
            
            if viewModel.yearGroups.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18)
                        .foregroundStyle(Color(hex: 0x868E96))
                    
                    Text("아직 함께하는 모임이 없어요!")
                        .whereFont(.body16medium)
                        .foregroundStyle(Color(hex: 0x495057))
                }
            } else {
                HistoryArea(viewModel.yearGroups, resolver)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("모임활동")
                    .whereFont(.subtitle18semibold)
                    .padding(.vertical, 14)
            }
        }
    }
}

// MARK: Nested Types
extension HistoryReminderView {
    struct ProfilesArea: View {
        let user: User
        let friend: FriendRelationship
        
        var body: some View {
            VStack {
                ZStack(alignment: .top) {
                    profile(nickname: user.nickname ?? String(), imageURL: user.imageURL, isMine: true)
                        .padding(.trailing, 80)
                    
                    profile(nickname: friend.nickname, imageURL: friend.imageURL, isMine: false)
                        .padding(.leading, 80)
                }
                
                Text("\(friend.nickname)님과 함께한 모임을 확인해보세요.")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x4B5563))
                    .padding(.vertical, 8)
            }
        }
        
        @ViewBuilder private func profile(nickname: String, imageURL: URL?, isMine: Bool) -> some View {
            VStack {
                AsyncImage(url: imageURL)
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: isMine ? 0 : 3)
                    )
                
                Text(isMine ? "나" : nickname)
                    .whereFont(.body16semibold)
                    .foregroundStyle(isMine ? Color(hex: 0x495057) : .black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.top, 8)
                    .frame(maxWidth: 100)
            }
        }
    }
    
    struct HistoryArea: View {
        private let yearGroups: [YearGroup]
        private let resolver: Resolver
        
        fileprivate init(
            _ yearGroups: [YearGroup],
            _ resolver: Resolver
        ) {
            self.yearGroups = yearGroups
            self.resolver = resolver
        }
        
        var body: some View {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(yearGroups) { yearGroup in
                        section(yearGroup)
                    }
                }
            }
            .padding(.horizontal)
            .scrollIndicators(.hidden)
        }
        
        @ViewBuilder private func section(_ yearGroup: YearGroup) -> some View {
            Section {
                LazyVStack {
                    ForEach(yearGroup.months) { monthGroup in
                        cell(monthGroup)
                    }
                }
            } header: {
                HStack {
                    Text(String(yearGroup.year))
                        .whereFont(.title24semibold)
                    
                    Spacer()
                    
                    Text("3개월 지난 모임은 포함되지 않습니다.")
                        .whereFont(.caption12regular)
                        .foregroundStyle(Color(hex: 0x6B7280))
                }
                .padding(.top)
            }
            .padding(.top)
        }
        
        @ViewBuilder private func cell(_ monthGroup: MonthGroup) -> some View {
            HStack(alignment: .top) {
                VStack(spacing: 38) {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(.accent)
                            .frame(width: 6, height: 6)
                            .background(
                                Circle()
                                    .fill(Color(hex: 0xEEF2FF))
                                    .frame(width: 10, height: 10)
                            )
                        
                        Text("\(monthGroup.month)월")
                            .whereFont(.body16medium)
                    }
                    .frame(maxWidth: 45)
                    
                    Rectangle()
                        .fill(Color(hex: 0xD1D5DB))
                        .frame(maxWidth: 1)
                        .frame(height: 116)
                }
                
                LazyVStack {
                    ForEach(monthGroup.meetings, id: \.id) { meeting in
                        meetingRow(meeting)
                    }
                }
            }
        }
        
        @ViewBuilder private func meetingRow(_ meeting: MeetingSummary) -> some View {
            VStack {
                HStack {
                    AsyncImage(url: meeting.imageURL)
                        .frame(width: 65, height: 65)
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.trailing, 10)
                    
                    VStack(alignment: .leading) {
                        Text(meeting.finishedAt.toString(by: .yyyyMMdd))
                        
                        Text(meeting.title)
                            .whereFont(.body16semibold)
                            .foregroundStyle(Color(hex: 0x111827))
                        
                        Text(meeting.description)
                    }
                    .whereFont(.caption12regular)
                    .foregroundStyle(Color(hex: 0x6B7280))
                    
                    Spacer()
                }
                .padding(.bottom, 10)
                
                NavigationLink {
                    MeetingInformationView(resolver: resolver, meetingID: meeting.id)
                } label: {
                    Text("자세히 보기")
                        .whereFont(.body14medium)
                        .foregroundColor(Color(hex: 0x343A40))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .strokeBorder(Color(hex: 0xDEE2E6))
                        )
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: 0xEEF2FF))
            )
        }
    }
}
