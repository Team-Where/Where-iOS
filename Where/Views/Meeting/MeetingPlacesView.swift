//
//  MeetingPlacesView.swift
//  Where
//
//  Created by Swain Yun on 1/10/25.
//

import SwiftUI

struct MeetingPlacesView: View {
    @State private var sortOption: PlaceSortOption = .all
    
    var body: some View {
        ScrollView(.vertical) {
            pickedPlacesArea([
                .init(),
                .init(),
                .init(),
            ])
            
            Rectangle()
                .foregroundStyle(Color(hex: 0xF3F4F6))
                .frame(height: 8)
            
            sortOptions
            
            candidatePlacesList(sortOption, users: [
                .init(nickname: "swain", isFavorite: false),
                .init(nickname: "죠니월드", isFavorite: true)
            ])
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder private func pickedPlacesArea(_ places: [Place]) -> some View {
        VStack {
            HStack {
                Image(.logoColorShort)
                
                Text("정한 장소")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(Color(hex: 0x1F2937))
                
                Spacer()
                
                Image(systemName: "info.circle")
                    .foregroundStyle(Color(hex: 0x9CA3AF))
            }
            .padding(.horizontal)
            
            if places.isEmpty {
                Text("아직 정한 장소가 없어요.")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x495057))
                    .frame(height: 150)
            } else {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(places, id: \.id) { place in
                            placeCell(place)
                        }
                    }
                }
                .scrollIndicators(.never)
                .contentMargins(20, for: .scrollContent)
            }
        }
        .padding(.top)
    }
    
    @ViewBuilder private func placeCell(_ place: Place) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 0) {
                Label {
                    Text("Pick")
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .whereFont(.body16medium)
                .foregroundStyle(.accent)
                .padding(.vertical, 8)
                
                ZStack {
                    AsyncImage(url: place.imageURL)
                        .frame(width: 220, height: 220)
                        .clipShape(.rect(cornerRadius: 16))
                    
                    VStack {
                        Image(systemName: "heart")
                        
                        Text("\(4)")
                    }
                    .whereFont(.caption12medium)
                    .padding(4)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.black.opacity(0.5))
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .offset(x: -10, y: -10)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: 0xF3F4F6))
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(Color(hex: 0x1F2937))
                
                Text(place.address)
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x4B5563))
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(.bubbleIcon)
                        
                        Text("코멘트 \(place.comments.count)")
                    }
                    .foregroundStyle(Color(hex: 0x868E96))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                        
                        Text("좋아요 \(place.likes)")
                    }
                    .foregroundStyle(.accent)
                }
                .whereFont(.caption12medium)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(.colorNaverMapLogo)
                        
                        Text("네이버 지도")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.white)
                            .strokeBorder(Color(hex: 0xE3E4E9))
                    )
                    
                    HStack(spacing: 4) {
                        Image(.colorKakaoMapLogo)
                        
                        Text("카카오맵")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.white)
                            .strokeBorder(Color(hex: 0xE3E4E9))
                    )
                }
                .whereFont(.caption12regular)
                .foregroundStyle(Color(hex: 0x282828))
            }
        }
    }
    
    private var sortOptions: some View {
        HStack(spacing: 8) {
            ForEach(PlaceSortOption.allCases, id: \.self) { option in
                Button {
                    sortOption = option
                } label: {
                    Text(option.title)
                        .whereFont(.body14medium)
                        .foregroundStyle(sortOption == option ? .black : Color(hex: 0x6B7280))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                                .strokeBorder(sortOption == option ? .black : .clear)
                        )
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder private func candidatePlacesList(_ sortOption: PlaceSortOption, users: [User]) -> some View {
        switch sortOption {
        case .all:
            LazyVStack {
                ForEach(users, id: \.id) { user in
                    sectionByUser(user, [
                        .init(),
                        .init(),
                        .init(),
                    ])
                }
            }
        case .byLikesDescending:
            LazyVStack {
                ForEach(1...3, id: \.self) { index in
                    sectionByLikes(index: index, [
                        .init(),
                        .init(),
                        .init(),
                    ])
                }
            }
        }
    }
    
    @ViewBuilder private func sectionByUser(_ user: User, _ places: [Place]) -> some View {
        Section {
            ForEach(places, id: \.id) { place in
                placesSectionCell(place)
            }
        } header: {
            HStack(spacing: 12) {
                AsyncImage(url: user.imageURL)
                    .frame(width: 40, height: 40)
                    .clipShape(.circle)
                
                Text(user.nickname)
                    .whereFont(.body16medium)
                    .foregroundStyle(Color(hex: 0x1F2937))
                
                Spacer()
                
                // TODO: "나" 일 때만 장소 공유 인터랙션 가능
                Button {
                    // TODO: 장소 공유 시트 연결
                } label: {
                    Label {
                        Text("장소 공유")
                            .whereFont(.body14medium)
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                    }
                }
            }
        }
        .padding([.horizontal, .top])
    }
    
    @ViewBuilder private func sectionByLikes(index: Int, _ places: [Place]) -> some View {
        Section {
            ForEach(places, id: \.id) { place in
                placesSectionCell(place)
            }
        } header: {
            VStack {
                Text("Best \(index)")
                    .whereFont(.subtitle18semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                
                Rectangle()
                    .frame(width: 80, height: 2)
            }
            .foregroundStyle(.accent)
        }
        .padding([.horizontal, .top])
    }
    
    @ViewBuilder private func placesSectionCell(_ place: Place) -> some View {
        VStack(spacing: 18) {
            HStack(spacing: 16) {
                AsyncImage(url: place.imageURL)
                    .frame(width: 80, height: 80)
                    .clipShape(.rect(cornerRadius: 16))
                    .overlay(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 17)
                            .fill(.accent)
                            .frame(width: 71, height: 19)
                            .overlay {
                                Text("같이 찾은 장소")
                                    .whereFont(.caption11regular)
                                    .foregroundStyle(.white)
                            }
                    }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(place.name)
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(Color(hex: 0x1F2937))
                    
                    Text(place.address)
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0x4B5563))
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(.bubbleIcon)
                            
                            Text("코멘트 \(place.comments.count)")
                        }
                        .foregroundStyle(Color(hex: 0x868E96))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                            
                            Text("좋아요 \(place.likes)")
                        }
                        .foregroundStyle(.accent)
                    }
                    .whereFont(.caption12medium)
                }
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(.colorNaverMapLogo)
                    
                    Text("네이버 지도")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(.white)
                        .strokeBorder(Color(hex: 0xE3E4E9))
                )
                
                HStack(spacing: 4) {
                    Image(.colorKakaoMapLogo)
                    
                    Text("카카오맵")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(.white)
                        .strokeBorder(Color(hex: 0xE3E4E9))
                )
            }
            .whereFont(.caption12regular)
            .foregroundStyle(Color(hex: 0x282828))
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .strokeBorder(Color(hex: 0xF3F4F6))
                .shadow(color: Color(hex: 0x566271).opacity(0.1), radius: 1, y: 4)
        )
        .padding(.bottom)
    }
}

// MARK: Nested Types
extension MeetingPlacesView {
    /// 장소 목록 정렬 조건
    enum PlaceSortOption: CaseIterable {
        /// 전체보기
        case all
        /// Likes 수 내림차순, 3위까지
        case byLikesDescending
        
        var title: String {
            switch self {
            case .all: "전체보기"
            case .byLikesDescending: "BEST 순위"
            }
        }
    }
}

#Preview {
    MeetingPlacesView()
}
