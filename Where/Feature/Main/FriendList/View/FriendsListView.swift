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

struct FriendsListView: View {
    @StateObject private var viewModel: FriendsListViewModel
    @FocusState private var isFocused: Bool
    @Binding private var navigationType: MainNavigationType?
    
    private let resolver: Resolver
    
    init(
        _ navigationType: Binding<MainNavigationType?>,
        resolver: Resolver
    ) {
        self._navigationType = navigationType
        self._viewModel = StateObject(wrappedValue: resolver.resolve(FriendsListViewModel.self)!)
        self.resolver = resolver
    }
    
    var body: some View {
        VStack {
            Header($viewModel.isEditing)
            
            SearchBar("친구를 검색하세요.", text: $viewModel.searchingText, $isFocused)
            
            if viewModel.friends.isEmpty {
                UnavailableView()
            } else {
                FriendsList(viewModel: viewModel)
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
        .sheet(item: $viewModel.sheetType) { type in
            switch type {
            case .deleteFriend(let friend):
                DeleteFriendSheet(viewModel: viewModel, friend: friend)
            case .historyWithFriend(let user, let friend):
                HistoryReminderSheet(viewModel: viewModel, $viewModel.sheetType, $navigationType, user: user, friend: friend, resolver: resolver)
            }
        }
    }
}

// MARK: - Subviews
private extension FriendsListView {
    struct Header: View {
        @Binding var isEditing: Bool
        
        init(_ isEditing: Binding<Bool>) {
            self._isEditing = isEditing
        }
        
        var body: some View {
            HStack {
                if isEditing {
                    BackButton { toggleEditMode() }
                }
                
                Text(isEditing ? "목록편집" : "친구목록")
                    .whereFont(isEditing ? .subtitle18semibold : .title24semibold)
                    .foregroundStyle(.where(.gray800))
                    .padding(.leading, isEditing ? 16 : 0)
                
                Spacer()
                
                Button {
                    toggleEditMode()
                } label: {
                    Text(isEditing ? "완료" : "편집")
                        .whereFont(.body16medium)
                }
                .tint(.accent)
            }
            .padding(.bottom)
        }
        
        func toggleEditMode() {
            withAnimation { isEditing.toggle() }
        }
    }
    
    struct UnavailableView: View {
        var body: some View {
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
    }
    
    struct FriendsList: View {
        @ObservedObject var viewModel: FriendsListViewModel
        
        private var friends: [FriendRelationship] { viewModel.friends }
        private var searchedFriends: [FriendRelationship] { viewModel.searchedFriends }
        private var isEditing: Bool { viewModel.isEditing }
        
        var body: some View {
            ScrollView(.vertical) {
                if viewModel.isEditing == false {
                    Section {
                        LazyVStack {
                            ForEach(viewModel.friends) { friend in
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
            .scrollIndicators(.never)
        }
        
        @ViewBuilder private func sectionHeader(type: SectionType, count: Int) -> some View {
            HStack {
                Text("\(type.title)(\(count))")
                
                Spacer()
            }
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
            Button {
                viewModel.presentHistoryWithFriend(friend: friend)
            } label: {
                HStack {
                    AsyncImage(url: friend.imageURL)
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(.circle)
                    
                    Text(friend.nickname)
                        .whereFont(.body16medium)
                    
                    Spacer()
                    
                    performButton
                }
            }
        }
        
        private var performButton: some View {
            Button {
                viewModel.isEditing ? viewModel.deleteFriend(by: friend.id) : viewModel.toggleFavorite(by: friend.id)
            } label: {
                Image(systemName: viewModel.isEditing ? "trash" : friend.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(viewModel.isEditing ? .where(hex: 0x6B7280) : friend.isFavorite ? .where(hex: 0xFBBF24) : .where(hex: 0xD1D5D8))
            }
            .transition(.move(edge: .trailing))
        }
    }
}

// MARK: - Sheet
private extension FriendsListView {
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
        @Binding var sheetType: SheetType?
        @Binding var navigationType: MainNavigationType?
        
        let user: User
        let friend: FriendRelationship
        let resolver: Resolver
        
        init(
            viewModel: FriendsListViewModel,
            _ sheetType: Binding<SheetType?>,
            _ navigationType: Binding<MainNavigationType?>,
            user: User,
            friend: FriendRelationship,
            resolver: Resolver
        ) {
            self.viewModel = viewModel
            self._sheetType = sheetType
            self._navigationType = navigationType
            self.user = user
            self.friend = friend
            self.resolver = resolver
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
                    sheetType = nil
                    navigationType = .historyReminderView(user: user, friend: friend)
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
}

#Preview {
    ContentView(resolver: PreviewHelper.shared.resolver)
}
