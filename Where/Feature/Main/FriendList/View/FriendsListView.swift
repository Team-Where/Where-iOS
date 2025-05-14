//
//  FriendsListView.swift
//  Where
//
//  Created by Swain Yun on 1/2/25.
//

import SwiftUI
import Swinject

fileprivate typealias SectionType = FriendsListViewModel.SectionType
fileprivate typealias SheetType = FriendsListViewModel.SheetType
fileprivate typealias Route = FriendsListViewModel.Route

struct FriendsListView: View {
    @ObservedObject private var viewModel: FriendsListViewModel
    @FocusState private var isFocused: Bool
    
    private var friends: [FriendRelationship] { viewModel.friends }
    private var searchedFriends: [FriendRelationship] { viewModel.searchedFriends }
    private var isEditing: Bool { viewModel.isEditing }
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.viewModel = resolver.resolve(FriendsListViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        VStack {
            SearchBar("친구를 검색하세요.", text: $viewModel.searchingText, $isFocused)
            
            if friends.isEmpty {
                unavailableView
            } else {
                content()
            }
        }
        .onTapGesture {
            isFocused = false
        }
        .padding()
        .overlay(alignment: .bottom) {
            Divider()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if isEditing {
                    BackButton {
                        withAnimation {
                            viewModel.toggleEditMode()
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigation) {
                if isEditing {
                    Text("목록편집")
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(Color(hex: 0x1F2937))
                        .padding(.leading)
                } else {
                    Text("친구목록")
                        .whereFont(.title24semibold)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        viewModel.toggleEditMode()
                    }
                } label: {
                    Text(isEditing ? "완료" : "편집")
                        .whereFont(.body16medium)
                }
            }
        }
        .sheet(item: $viewModel.sheetType) { type in
            switch type {
            case .deleteFriend(let friend):
                DeleteFriendSheet(viewModel: viewModel, friend: friend)
            case .historyWithFriend(let user, let friend):
                HistoryReminderSheet(viewModel: viewModel, user: user, friend: friend)
            }
        }
        .navigationDestination(item: $viewModel.route) { route in
            switch route {
            case .historyReminder(let user, let friend):
                HistoryReminderView(user: user, friend: friend, resolver: resolver)
            }
        }
    }
    
    private var unavailableView: some View {
        VStack {
            HStack {
                Text("친구(\(0))")
                    .whereFont(.body16medium)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18)
                    .foregroundStyle(Color(hex: 0x868E96))
                
                Text("아직 만난 친구가 없어요!")
                    .whereFont(.body16medium)
                    .foregroundStyle(Color(hex: 0x495057))
                
                Spacer()
            }
        }
        .padding(.top)
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView(.vertical) {
            if isEditing == false {
                Section {
                    LazyVStack {
                        ForEach(friends) { friend in
                            Cell(viewModel: viewModel, friend)
                        }
                    }
                } header: {
                    sectionHeader(type: .favorite, count: friends.count)
                }
                .padding(.top)
            }
            
            Section {
                LazyVStack {
                    ForEach(friends) { friend in
                        Cell(viewModel: viewModel, friend)
                    }
                }
            } header: {
                sectionHeader(type: .common, count: friends.count)
            }
            .padding(.top)
        }
    }
    
    @ViewBuilder private func sectionHeader(type: SectionType, count: Int) -> some View {
        HStack {
            Text("\(type.title)(\(count))")
            
            Spacer()
        }
    }
}

// MARK: Nested Types
extension FriendsListView {
    struct DeleteFriendSheet: View {
        @ObservedObject private var viewModel: FriendsListViewModel
        
        private let friend: FriendRelationship
        
        init(
            viewModel: FriendsListViewModel,
            friend: FriendRelationship
        ) {
            self.viewModel = viewModel
            self.friend = friend
        }
        
        var body: some View {
            Button {
                viewModel.deleteFriend(by: friend.id)
            } label: {
                if viewModel.isDeletionProcessing {
                    ProgressView()
                } else {
                    Text("친구 삭제")
                        .whereFont(.body16medium)
                        .foregroundStyle(Color(hex: 0xEF4444))
                        .frame(maxWidth: .infinity, maxHeight: 23)
                        .padding()
                        .background(Color(hex: 0xF3F4F6))
                        .clipShape(.rect(cornerRadius: 16))
                }
            }
            .padding(.horizontal)
            .presentationDetents([.height(150)])
            .presentationCornerRadius(16)
        }
    }
    
    struct HistoryReminderSheet: View {
        @ObservedObject private var viewModel: FriendsListViewModel
        
        let user: User
        let friend: FriendRelationship
        
        init(
            viewModel: FriendsListViewModel,
            user: User,
            friend: FriendRelationship
        ) {
            self.viewModel = viewModel
            self.user = user
            self.friend = friend
        }
        
        var body: some View {
            VStack {
                HStack {
                    Button {
                        viewModel.dismissSheet()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x030712))
                    }
                    
                    Spacer()
                    
                    Image(systemName: friend.isFavorite ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(friend.isFavorite ? Color(hex: 0xFBBF24) : Color(hex: 0xD1D5D8))
                }
                
                VStack(spacing: 18) {
                    AsyncImage(url: friend.imageURL)
                        .frame(width: 120, height: 120)
                        .clipShape(.circle)
                    
                    VStack(spacing: 6) {
                        Text("\(viewModel.meetingsCount)번 만남")
                            .whereFont(.caption12regular)
                            .foregroundStyle(.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(hex: 0xEEF2FF))
                            .clipShape(.rect(cornerRadius: 26))
                        
                        Text(friend.nickname)
                            .whereFont(.body16medium)
                    }
                }
                
                Button {
                    viewModel.presentHistoryReminder(friend: friend)
                } label: {
                    Text("나와의 모임활동 보기")
                        .whereFont(.body16medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.accent)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
            .padding()
            .presentationDetents([.fraction(0.45)])
            .presentationCornerRadius(16)
        }
    }
    
    struct Cell: View {
        @ObservedObject private var viewModel: FriendsListViewModel

        private let friend: FriendRelationship
        
        fileprivate init(
            viewModel: FriendsListViewModel,
            _ friend: FriendRelationship
        ) {
            self.viewModel = viewModel
            self.friend = friend
        }
        
        var body: some View {
            HStack {
                AsyncImage(url: friend.imageURL)
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(.circle)
                
                Text(friend.nickname)
                    .whereFont(.body16medium)
                
                Spacer()
                
                Button {
                    viewModel.isEditing ? viewModel.deleteFriend(by: friend.id) : viewModel.toggleFavorite(by: friend.id)
                } label: {
                    Image(systemName: viewModel.isEditing ? "trash" : friend.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(viewModel.isEditing ? .where(hex: 0x6B7280) : friend.isFavorite ? .where(hex: 0xFBBF24) : .where(hex: 0xD1D5D8))
                }
                .transition(.move(edge: .trailing))
            }
            .contentShape(.rect)
            .onTapGesture {
                viewModel.presentHistoryWithFriend(friend: friend)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView(resolver: PreviewHelper.shared.resolver)
    }
}
