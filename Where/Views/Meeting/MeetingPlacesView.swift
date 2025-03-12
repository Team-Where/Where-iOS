//
//  MeetingPlacesView.swift
//  Where
//
//  Created by Swain Yun on 1/10/25.
//

import SwiftUI

struct MeetingPlacesView: View {
    @State private var sortOption: PlaceSortOption = .all
    @State private var isPickTipPresented: Bool = false
    @State private var isShareTipPresented: Bool = false
    
    private let tipConfiguration = ToolTipConfiguration(arrowPosition: .topTrailing)
    
    var body: some View {
        ScrollView(.vertical) {
            pickedPlacesArea([
                Place(id: 1, userId: 1, meetingId: 1, name: "TYPE", address: "서울 용산구 한강대로21길 18 1층", createdAt: .now, updatedAt: .now, likesCount: 1, status: .picked, comments: [Comment(placeId: 1, description: "좋아요", writerId: 1, createdAt: .now, updatedAt: .now)]),
                
                Place(id: 2, userId: 1, meetingId: 1, name: "TYPE", address: "서울 용산구 한강대로21길 18 1층", createdAt: .now, updatedAt: .now, likesCount: 1, status: .picked, comments: [Comment(placeId: 1, description: "좋아요", writerId: 1, createdAt: .now, updatedAt: .now)]),
                
                Place(id: 3, userId: 1, meetingId: 1, name: "TYPE", address: "서울 용산구 한강대로21길 18 1층", createdAt: .now, updatedAt: .now, likesCount: 1, status: .picked, comments: [Comment(placeId: 1, description: "좋아요", writerId: 1, createdAt: .now, updatedAt: .now)])
            ])
            
            Rectangle()
                .foregroundStyle(Color(hex: 0xF3F4F6))
                .frame(height: 8)
            
            sortOptions
            
            candidatePlacesList(sortOption, users: [
                User(id: 1)
            ])
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(.interaction, .containerRelative)
        .onTapGesture {
            withAnimation {
                isPickTipPresented = false
                isShareTipPresented = false
            }
        }
    }
    
    @ViewBuilder private func pickedPlacesArea(_ places: [Place]) -> some View {
        VStack {
            HStack {
                Image(.logoColorShort)
                
                Text("정한 장소")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(Color(hex: 0x1F2937))
                
                Spacer()
                
                Button {
                    withAnimation {
                        isPickTipPresented.toggle()
                    }
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Color(hex: 0x9CA3AF))
                }
                .whereTip($isPickTipPresented, configuration: tipConfiguration) {
                    Text("친구들과 가기로 결정한 장소 목록입니다")
                        .whereFont(.caption12regular)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                }
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
                        Place(id: 1, userId: 1, meetingId: 1, name: "TYPE", address: "서울 용산구 한강대로21길 18 1층", createdAt: .now, updatedAt: .now, likesCount: 1, status: .picked, comments: [Comment(placeId: 1, description: "좋아요", writerId: 1, createdAt: .now, updatedAt: .now)]),
                        
                        Place(id: 2, userId: 1, meetingId: 1, name: "TYPE", address: "서울 용산구 한강대로21길 18 1층", createdAt: .now, updatedAt: .now, likesCount: 0, status: .picked, comments: []),
                        
                        Place(id: 3, userId: 1, meetingId: 1, name: "TYPE", address: "서울 용산구 한강대로21길 18 1층", createdAt: .now, updatedAt: .now, likesCount: 1, status: .picked, comments: [Comment(placeId: 1, description: "좋아요", writerId: 1, createdAt: .now, updatedAt: .now)])
                    ])
                }
            }
        case .byLikesDescending:
            LazyVStack {
                ForEach(1...3, id: \.self) { index in
                    sectionByLikes(index: index, [])
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
                if true {
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
                    .whereTip($isShareTipPresented, configuration: tipConfiguration) {
                        Text("가장 먼저 장소를 공유해보세요!")
                            .whereFont(.caption12regular)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
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
        VStack(alignment: .leading, spacing: 10) {
            // TODO: 2명 이상의 Pick을 받은 장소만 뱃지 노출
            if true {
                Text("같이 찾은 장소")
                    .whereFont(.caption11regular)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(.accent)
                    .clipShape(.rect(cornerRadius: 17))
            }
            
            HStack(spacing: 16) {
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
                            
                            if place.comments.count > 0 {
                                Text("코멘트 \(place.comments.count)")
                            } else {
                                Text("코멘트")
                            }
                        }
                        .foregroundStyle(Color(hex: 0x868E96))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                            
                            if place.likesCount > 0 {
                                Text("좋아요 \(place.likesCount)")
                            } else {
                                Text("좋아요")
                            }
                        }
                        .foregroundStyle(place.likesCount > 0 ? .accent : Color(hex: 0x868E96))
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
                .shadow(color: .where(.gray200), radius: 4, y: 4)
        )
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
    
    struct PlaceCell: View {
        @State private var isPicked: Bool = false
        
        private let place: Place
        
        init(place: Place) {
            self.place = place
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Button {
                    isPicked.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Text("Pick")
                            .whereFont(.body14medium)
                            .foregroundStyle(isPicked ? .accent : .where(.gray400))
                        
                        Image(.whereCheckmark)
                            .background(
                                Circle()
                                    .fill(isPicked ? .accent : .where(.gray400))
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(.where(.gray800))
                    
                    Text(place.address)
                        .whereFont(.body14regular)
                        .foregroundStyle(.where(.gray600))
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(.bubbleIcon)
                        
                        Text("코멘트 \(place.comments.count)")
                    }
                    .foregroundStyle(Color(hex: 0x868E96))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                        
                        Text("좋아요 \(place.likesCount)")
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
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .where(.gray200), radius: 4, y: 4)
            )
        }
    }
}

#Preview {
    MeetingPlacesView()
}
