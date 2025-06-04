//
//  InviteFriendsView.swift
//  Where
//
//  Created by Swain Yun on 1/8/25.
//

import SwiftUI
import Swinject

fileprivate typealias FriendCellDataSource = InviteFriendsViewModel.FriendCellDataSource

struct InviteFriendsView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel:InviteFriendsViewModel
    @FocusState private var isFocused: Bool
    
    private let meetingID: UInt64
    
    init(
        meetingID: UInt64,
        resolver: Resolver
    ) {
        self.meetingID = meetingID
        self._viewModel = StateObject(wrappedValue: resolver.resolve(InviteFriendsViewModel.self)!)
    }
    
    var body: some View {
        ZStack {
            if viewModel.isSearching {
                VStack {
                    HStack(spacing: 16) {
                        SearchBar("검색", text: $viewModel.searchingText, $isFocused)
                        
                        Button {
                            isFocused = false
                            viewModel.isSearching.toggle()
                            viewModel.searchingText.removeAll()
                        } label: {
                            Text("취소")
                                .whereFont(.body16medium)
                                .foregroundStyle(Color(hex: 0x1F2937))
                        }
                    }
                    .frame(maxHeight: 48)
                    .padding(.bottom)
                    
                    if viewModel.searchedFriends.isEmpty {
                        Spacer()
                        
                        Text("검색 결과가 없습니다.")
                            .whereFont(.body16regular)
                            .foregroundStyle(Color(hex: 0x374151))
                        
                        Spacer()
                    } else {
                        ScrollView(.vertical) {
                            LazyVStack {
                                ForEach(viewModel.searchedFriends, id: \.id) { friend in
                                    friendsListCell(friend)
                                }
                            }
                        }
                    }
                }
            } else {
                ScrollView(.vertical) {
                    invitedFriends()
                    
                    Button {
                        viewModel.inviteFriendWithKakao { openURL($0) }
                    } label: {
                        Image(.kakaoInvitationButton)
                            .resizable()
                            .scaledToFit()
                    }
                    .padding(.vertical)
                    
                    friendsList(viewModel.friendsDataSource)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isSearching == false {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton()
                }
                
                ToolbarItem(placement: .principal) {
                    Text("친구 초대")
                        .whereFont(.subtitle18semibold)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isSearching.toggle()
                        isFocused = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(Color(hex: 0x1F2937))
                    }
                }
            }
        }
        .scrollIndicators(.never)
        .floater($viewModel.floaterType) { type in
            switch type {
            case .invited:
                Image(systemName: "checkmark")
                    .foregroundStyle(.accent)
            case .errorOccured:
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
            }
        }
        .padding([.top, .horizontal])
        .onAppear {
            viewModel.setMeeting(id: meetingID)
        }
    }
    
    @ViewBuilder private func invitedFriends() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("초대된 친구 \(viewModel.invitedFriends.count)")
                    .whereFont(.body16semibold)
                    .foregroundStyle(Color(hex: 0x1F2937))
                
                Spacer()
                
                Text("대기중 \(viewModel.pendingFriends.count)")
                    .whereFont(.caption12regular)
                    .foregroundStyle(Color(hex: 0x6B7280))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color(hex: 0xF3F4F6))
                    )
            }
            
            Divider()
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(viewModel.invitationStates, id: \.guestID) { state in
                        VStack {
                            AsyncImage(url: state.guestImageURL) { image in
                                image
                                    .frame(width: 40, height: 40)
                                    .clipShape(.circle)
                            } placeholder: {
                                Image(.person)
                                    .frame(width: 40, height: 40)
                                    .clipShape(.circle)
                            }
                            Text(state.guestName)
                                .whereFont(.body14medium)
                                .foregroundStyle(Color(hex: 0x374151))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .opacity(state.isInvited ? 1.0 : 0.8)
                        
                    }
                }
            }
            .frame(maxHeight: 68)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .strokeBorder(Color(hex: 0xF3F4F6))
                .shadow(color: Color(hex: 0x566271).opacity(0.1), radius: 1, y: 4)
        )
    }
    
    @ViewBuilder private func friendsList(_ friends: [FriendCellDataSource]) -> some View {
        LazyVStack(spacing: 20) {
            Section {
                ForEach(friends, id: \.id) { friend in
                    friendsListCell(friend)
                }
            } header: {
                sectionHeader("최근 만난 친구", count: 3)
            }
            
            Section {
                ForEach(friends, id: \.id) { friend in
                    friendsListCell(friend)
                }
            } header: {
                sectionHeader("모든친구", count: 23)
            }
        }
    }
    
    @ViewBuilder private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text("\(title) \(count)")
                .whereFont(.body14medium)
                .foregroundStyle(Color(hex: 0x4B5563))
            
            Spacer()
        }
        .padding(.top)
    }
    
    @ViewBuilder private func friendsListCell(_ dataSource: FriendCellDataSource) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: dataSource.friend.imageURL)
                .frame(width: 40, height: 40)
                .clipShape(.circle)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dataSource.friend.nickname)
                    .whereFont(.body16medium)
                    .foregroundStyle(Color(hex: 0x1F2937))
                
                Text("\(dataSource.meetingCount)번 만남")
                    .whereFont(.caption11regular)
                    .foregroundStyle(Color(hex: 0x9CA3AF))
            }
            
            Spacer()
            
            if dataSource.isInvited {
                HStack {
                    Image(systemName: "checkmark")
                    
                    Text("완료")
                }
                .whereFont(.body14medium)
                .foregroundStyle(.accent)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: 0xF1F3F5))
                        .strokeBorder(Color(hex: 0xDEE2E6))
                        .frame(width: 72, height: 32)
                )
            } else {
                Button {
                    withAnimation {
                        viewModel.inviteFriend(dataSource.friend)
                    }
                } label: {
                    Text("초대")
                        .whereFont(.body14medium)
                        .foregroundStyle(.accent)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .strokeBorder(Color(hex: 0xDEE2E6))
                                .frame(width: 52, height: 32)
                        )
                }
            }
        }
    }
}
