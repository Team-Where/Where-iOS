//
//  MeetingPlacesView.swift
//  Where
//
//  Created by Swain Yun on 1/10/25.
//

import SwiftUI
import Swinject

fileprivate typealias PlaceSortOption = MeetingPlacesViewModel.PlaceSortOption
fileprivate typealias SheetType = MeetingPlacesViewModel.SheetType

struct MeetingPlacesView: View {
    @State private var sheetType: SheetType?
    @State private var isPickTipPresented: Bool = false
    @State private var isShareTipPresented: Bool = false
    @State private var viewModel: MeetingPlacesViewModel
    
    private let tipConfiguration = ToolTipConfiguration(arrowPosition: .topTrailing)
    private let meetingID: UInt64
    private let isMeetingFinished: Bool
    private let resolver: Resolver
    
    init(
        resolver: Resolver,
        meetingID: UInt64,
        isFinished: Bool
    ) {
        self.meetingID = meetingID
        self.isMeetingFinished = isFinished
        self.viewModel = resolver.resolve(MeetingPlacesViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        VStack {
            pickedPlacesArea(viewModel.pickedPlaces)
            
            Rectangle()
                .foregroundStyle(Color(hex: 0xF3F4F6))
                .frame(height: 8)
            
            sortOptions
            
            Group {
                if viewModel.places.isEmpty {
                    VStack {
                        Spacer()
                        
                        Text("아직 공유된 장소가 없어요.")
                            .whereFont(.body14regular)
                            .foregroundStyle(.where(.gray700))
                        
                        Spacer()
                    }
                } else {
                    ScrollView(.vertical) {
                        switch viewModel.sortOption {
                        case .all:
                            LazyVStack {
                                ForEach(viewModel.places) { place in
                                    placeListCell(place)
                                }
                            }
                        case .byLikesDescending:
                            LazyVStack {
                                ForEach(viewModel.placesSortedByLikes.indices, id: \.self) { index in
                                    sectionByLikes(index: index, viewModel.placesSortedByLikes[index])
                                }
                            }
                        }
                    }
                }
            }
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
        .sheet(item: $sheetType) { type in
            switch type {
            case .sharePlace: SharePlaceSheet(sheetType: $sheetType)
            }
        }
        .onAppear {
            viewModel.onAppear(meetingID: meetingID)
        }
    }
    
    @ViewBuilder private func pickedPlacesArea(_ places: [Place]) -> some View {
        ZStack(alignment: .top) {
            Group {
                if places.isEmpty {
                    Text("아직 정한 장소가 없어요.")
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0x495057))
                        .frame(height: 150)
                } else {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(places, id: \.id) { place in
                                PlaceCell(place: place)
                            }
                        }
                    }
                    .scrollIndicators(.never)
                    .contentMargins(20, for: .scrollContent)
                }
            }
            .padding(.top, 26)
            
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
        }
        .padding(.top)
    }
    
    private var sortOptions: some View {
        HStack(spacing: 8) {
            ForEach(PlaceSortOption.allCases, id: \.self) { option in
                Button {
                    withAnimation {
                        viewModel.changeSortOption(option: option)
                    }
                } label: {
                    Text(option.title)
                        .whereFont(.body14medium)
                        .foregroundStyle(viewModel.sortOption == option ? .black : Color(hex: 0x6B7280))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                                .strokeBorder(viewModel.sortOption == option ? .black : .clear)
                        )
                }
            }
            
            Spacer()
            
            if isMeetingFinished == false {
                Button {
                    sheetType = .sharePlace
                } label: {
                    Label {
                        Text("장소 공유")
                            .whereFont(.body14medium)
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
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
        }
        .padding()
    }
    
    @ViewBuilder private func sectionByLikes(index: Int, _ places: [Place]) -> some View {
        Section {
            ForEach(places, id: \.id) { place in
                placeListCell(place)
            }
        } header: {
            VStack {
                Text("Best \(index + 1)")
                    .whereFont(.subtitle18semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                
                Rectangle()
                    .frame(width: 80, height: 2)
            }
            .foregroundStyle(.accent)
        }
        .padding(.top)
    }
    
    @ViewBuilder private func placeListCell(_ place: Place) -> some View {
        NavigationLink {
            PlaceDetailView(place, resolver: resolver)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                if place.isSimulaneouslyShared {
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
                                
                                Text(place.commentsCount > .zero ? "코멘트 \(place.commentsCount)" : "코멘트")
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
                    .strokeBorder(.where(.gray100))
                    .shadow(color: .where(.gray200), radius: 4, y: 4)
            )
            .padding()
        }
    }
}

// MARK: Nested Types
extension MeetingPlacesView {
    struct PlaceCell: View {
        private let place: Place
        
        init(place: Place) {
            self.place = place
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 4) {
                    Text("Pick")
                        .whereFont(.body14medium)
                        .foregroundStyle(.accent)
                    
                    Image(.whereCheckmark)
                        .background(
                            Circle()
                                .fill(.accent)
                        )
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
                        
                        Text("코멘트 \(place.commentsCount)")
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
                    .strokeBorder(.where(.gray100))
                    .shadow(color: .where(.gray200), radius: 4, y: 4)
            )
        }
    }
    
    struct SharePlaceSheet: View {
        @Environment(\.openURL) private var openURL
        @Binding fileprivate var sheetType: SheetType?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    Text("장소 공유")
                        .whereFont(.subtitle18semibold)
                    
                    Spacer()
                    
                    Button {
                        sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding([.top, .horizontal])
                .padding(.top)
                
                Button {
                    guard let url = MapAppScheme.navermap.openURL() else { return }
                    openURL(url)
                } label: {
                    HStack(spacing: 16) {
                        Image(.colorNaverMapLogo)
                        
                        Text("네이버 지도에서 공유하기")
                            .whereFont(.body16medium)
                            .foregroundStyle(Color(hex: 0x282828))
                    }
                }
                .padding(.horizontal)
                
                Button {
                    guard let url = MapAppScheme.kakaomap.openURL() else { return }
                    openURL(url)
                } label: {
                    HStack(spacing: 16) {
                        Image(.colorKakaoMapLogo)
                        
                        Text("카카오맵에서 공유하기")
                            .whereFont(.body16medium)
                            .foregroundStyle(Color(hex: 0x282828))
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .presentationDetents([.fraction(0.27)])
            .presentationCornerRadius(16)
        }
    }
}
