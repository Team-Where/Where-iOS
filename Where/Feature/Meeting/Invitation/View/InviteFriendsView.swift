//
//  InviteFriendsView.swift
//  Where
//
//  Created by Swain Yun on 1/8/25.
//

import SwiftUI
import Swinject

struct InviteFriendsView: View {
    @ObservedObject private var viewModel:InviteFriendsViewModel
    @FocusState private var isFocused: Bool
    
    private let resolver: Resolver
    
    init(
        meetingID: UInt64,
        resolver: Resolver
    ) {
        self.viewModel = resolver.resolve(InviteFriendsViewModel.self)!
        self.resolver = resolver
        self.viewModel.setMeeting(id: meetingID)
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
                        // TODO: KakaoTalk Universal Link
                    } label: {
                        Image(.kakaoInvitationButton)
                            .resizable()
                            .scaledToFit()
                    }
                    .padding(.vertical)
                    
                    friendsList([])
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
        .floater($viewModel.isFloaterPresented, title: "초대되었습니다.") {
            Image(systemName: "checkmark")
                .foregroundStyle(.accent)
        }
        .padding([.top, .horizontal])
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
    
    @ViewBuilder private func friendsList(_ friends: [FriendRelationship]) -> some View {
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
    
    @ViewBuilder private func friendsListCell(_ friend: FriendRelationship) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: friend.imageURL)
                .frame(width: 40, height: 40)
                .clipShape(.circle)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.nickname)
                    .whereFont(.body16medium)
                    .foregroundStyle(Color(hex: 0x1F2937))
                
                Text("\(2)번 만남")
                    .whereFont(.caption11regular)
                    .foregroundStyle(Color(hex: 0x9CA3AF))
            }
            
            Spacer()
            
            // TODO: 도메인 모델 나오면 수정 예정
            Button {
                
            } label: {
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
            }
            
            // TODO: 도메인 모델 나오면 수정 예정
            Button {
                viewModel.inviteFriend(friend)
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
