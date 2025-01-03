//
//  FriendsListView.swift
//  Where
//
//  Created by Swain Yun on 1/2/25.
//

import SwiftUI

struct User: Identifiable {
    let id: UUID = UUID()
    let imageURL: URL? = nil
    let nickname: String
    let isFavorite: Bool
}

struct FriendsListView: View {
    @State private var searchingText: String = String()
    @State private var friends: [User] = [
        .init(nickname: "Swain", isFavorite: false),
        .init(nickname: "즐겨찾기한 친구", isFavorite: true),
        .init(nickname: "삭제될 친구", isFavorite: true),
    ]
    @State private var isSearching: Bool = false
    @State private var sheetItem: SheetType?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            header
            
            SearchBar("친구를 검색하세요.", text: $searchingText, $isFocused)
            
            if friends.isEmpty {
                unavailableView
            } else {
                ScrollView(.vertical) {
                    section(.favorite, friends.filter { $0.isFavorite })
                    section(.common, friends)
                }
            }
        }
        .padding()
        .sheet(item: $sheetItem) { item in
            sheet(item)
        }
    }
    
    private var header: some View {
        HStack {
            if isSearching {
                Button {
                    withAnimation {
                        isSearching.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.backward")
                            .padding(.leading, 14)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.black)
                        
                        Text("목록편집")
                            .whereFont(.subtitle18semibold)
                            .foregroundStyle(Color(hex: 0x1F2937))
                            .padding(.leading)
                    }
                }
            } else {
                Text("친구목록")
                    .whereFont(.title24semibold)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    isSearching.toggle()
                }
            } label: {
                Text(isSearching ? "완료" : "편집")
                    .whereFont(.body16medium)
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
    
    @ViewBuilder private func section(_ type: SectionType, _ friends: [User]) -> some View {
        if friends.isEmpty == false {
            Section {
                ForEach(friends) { friend in
                    HStack {
                        AsyncImage(url: friend.imageURL)
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(.circle)
                        
                        Text(friend.nickname)
                            .whereFont(.body16medium)
                        
                        Spacer()
                        
                        if isSearching {
                            Button {
                                sheetItem = .deleteFriend(friend: friend)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(Color(hex: 0x6B7280))
                            }
                            .transition(.move(edge: .trailing))
                        } else {
                            Button {
                                // TODO: 즐겨찾기 토글
                            } label: {
                                let isFavorite = friend.isFavorite
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .foregroundStyle(isFavorite ? Color(hex: 0xFBBF24) : Color(hex: 0xD1D5D8))
                            }
                            .transition(.move(edge: .trailing))
                        }
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        sheetItem = .historyWithFriend(friend: friend)
                    }
                }
            } header: {
                HStack {
                    Text("\(type.title)(\(friends.count))")
                    
                    Spacer()
                }
            }
            .padding(.top)
        }
    }
    
    @ViewBuilder private func sheet(_ type: SheetType) -> some View {
        switch type {
        case .deleteFriend(let friend):
            Button {
                // TODO: 친구 삭제
                guard let index = friends.firstIndex(where: { friend.id == $0.id }) else { return }
                friends.remove(at: index)
            } label: {
                Text("친구 삭제")
                    .whereFont(.body16medium)
                    .foregroundStyle(Color(hex: 0xEF4444))
                    .frame(maxWidth: .infinity, maxHeight: 23)
                    .padding()
                    .background(Color(hex: 0xF3F4F6))
                    .clipShape(.rect(cornerRadius: 16))
            }
            .padding(.horizontal)
            .presentationDetents([.height(150)])
        case .historyWithFriend(let friend):
            VStack {
                HStack {
                    let isFavorite = friend.isFavorite
                    
                    Button {
                        sheetItem = nil
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x030712))
                    }
                    
                    Spacer()
                    
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(isFavorite ? Color(hex: 0xFBBF24) : Color(hex: 0xD1D5D8))
                }
                
                VStack(spacing: 18) {
                    AsyncImage(url: friend.imageURL)
                        .frame(width: 120, height: 120)
                        .clipShape(.circle)
                    
                    VStack(spacing: 6) {
                        // TODO: 모델에 추가해야할 프로퍼티
                        Text("3번 만남")
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
                
                NavigationLink {
                    // TODO: 모임활동 화면으로 이동
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
        }
    }
}

// MARK: Nested Types
extension FriendsListView {
    /// 친구목록 내에서 구분되는 섹션의 종류
    enum SectionType {
        /// 일반 친구
        case common
        /// 즐겨찾기 친구
        case favorite
        
        var title: String {
            switch self {
            case .common: "친구"
            case .favorite: "즐겨찾기"
            }
        }
    }
    
    /// 친구목록 내에서 라우팅 가능한 시트의 종류
    enum SheetType: Identifiable, Hashable {
        /// 친구삭제
        case deleteFriend(friend: User)
        /// 나와의 모임활동 보기
        case historyWithFriend(friend: User)
        
        var id: String { String(describing: self) }
        
        static func == (lhs: FriendsListView.SheetType, rhs: FriendsListView.SheetType) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

#Preview {
    FriendsListView()
}