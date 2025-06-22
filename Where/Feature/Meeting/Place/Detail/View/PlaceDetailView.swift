//
//  PlaceDetailView.swift
//  Where
//
//  Created by 이현호 on 1/18/25.
//

import SwiftUI
import Swinject

struct PlaceDetailView: View {
    @Environment(\.openURL) private var openURL
    @State private var sheetType: SheetType?
    @State private var isTipPresented = false
    @State private var commentEditStep: EditStep?
    
    private let tipConfiguration = ToolTipConfiguration(arrowPosition: .topTrailing, backgroundColor: .accent, cornerRadius: 4)
    private let place: Place
    private let viewModel: PlaceDetailViewModel
    private let resolver: Resolver
    
    private var isPicked: Bool { place.pickedState == .picked }
    
    init(
        _ place: Place,
        resolver: Resolver
    ) {
        self.place = place
        self.viewModel = resolver.resolve(PlaceDetailViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                placeInfoArea(place)
                
                profileImagesArea(place.sharedUserImageURLs)
                
                mapButtonsArea
                
                pickButtonArea()
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)
            
            VStack {
                Rectangle()
                    .foregroundStyle(Color(hex: 0xF1F3F5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 8)
                    .padding(.vertical, 32)
            }
            
            CommentView(sheetType: $sheetType, commentEditStep: $commentEditStep, viewModel: viewModel,place: place)
        }
        .scrollIndicators(.never)
        .onAppear {
            viewModel.onApear(place.id)
            isTipPresented = place.pickedState == .unpicked
            
            guard isTipPresented == true else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.isTipPresented = false
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    sheetType = .placeDelete
                } label: {
                    Text("삭제")
                        .whereFont(.body16medium)
                }
            }
        }
        .sheet(item: $sheetType) { type in
            switch type {
            case .placeDelete:
                PlaceDelete(isProcessing: viewModel.isDeletionProcessing) {
                    viewModel.deletePlace(id: place.id)
                }
            case .comment(let text):
                CommentSheet(text: text, editStep: $commentEditStep, sheetType: $sheetType, viewModel: viewModel)
            }
        }
        .onReceive(viewModel.sheetPublisher) {
            sheetType = $0
        }
    }
    
    enum SheetType: Identifiable {
        var id: Int {
            switch self {
            case .placeDelete: 0
            case .comment: 1
            }
        }
        
        case placeDelete
        case comment(text: String?)
    }
    
    @ViewBuilder private func placeInfoArea(_ place: Place) -> some View {
        VStack(spacing: 12) {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.where(hex: 0xD9D9D9))
                    .frame(width: 220, height: 220)
                    .overlay {
                        Image(.logoShortWhite)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 89)
                    }
                    .overlay(alignment: .topLeading) {
                        if place.isSimulaneouslyShared {
                            Text("같이 찾은 장소")
                                .whereFont(.caption11regular)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 17)
                                        .fill(.accent)
                                )
                                .offset(x: 8, y: 8)
                        }
                    }
                
                Text(place.name)
                    .whereFont(.title24semibold)
                    .foregroundStyle(.where(.gray800))
                
                Text(place.address)
                    .whereFont(.body16regular)
                    .foregroundStyle(.where(.gray600))
            }
            
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(.bubbleIcon)
                    
                    Text(viewModel.comments.count > 0 ? "코멘트 \(viewModel.comments.count)" : "코멘트")
                }
                .foregroundStyle(.where(hex: 0x868E96))
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                    
                    Text(place.likesCount > 0 ? "좋아요 \(place.likesCount)" : "좋아요")
                }
                .foregroundStyle(place.isLikedByMe ? .accent : .where(hex: 0x868E96))
            }
            .whereFont(.body14medium)
        }
    }
    
    @ViewBuilder private func profileImagesArea(_ urls: [URL?]) -> some View {
        let spacing: CGFloat = 26
        let maxDisplayCount: Int = 5
        let displayCount: Int = maxDisplayCount - 1
        
        ZStack(alignment: .leading) {
            ForEach(urls.prefix(maxDisplayCount).indices, id: \.self) { index in
                profileImageCell(url: urls[index], index: index, displayCount: displayCount, cellCount: urls.count)
                    .offset(x: CGFloat(index) * spacing)
            }
        }
        .frame(
            width: min(urls.count, maxDisplayCount) > 0 ?
            CGFloat(min(urls.count, maxDisplayCount) - 1) * spacing + 40 :
                40, alignment: .leading
        )
    }
    
    @ViewBuilder private func profileImageCell(url: URL?, index: Int, displayCount: Int, cellCount: Int) -> some View {
        AsyncImage(url: url)
            .frame(width: 40, height: 40)
            .clipShape(.circle)
            .overlay {
                Circle()
                    .stroke(.white, lineWidth: 2)
                
                if index == displayCount, cellCount > displayCount {
                    Text("+\(cellCount - displayCount)")
                        .whereFont(.body16medium)
                        .foregroundStyle(.white)
                        .clipShape(.circle)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(.black.opacity(0.6))
                        )
                }
            }
    }
    
    private var mapButtonsArea: some View {
        HStack(spacing: 8) {
            Button {
                if MapAppScheme.navermap.isAppInstalled(),
                   let url = MapAppScheme.navermap.openURL() {
                    openURL(url)
                }
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    
                    Image(.naverMapLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("네이버 지도")
                        .whereFont(.body14regular)
                        .foregroundStyle(.where(hex: 0x282828))
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.white)
                        .strokeBorder(.where(hex: 0xE3E4E9))
                )
            }
            
            Button {
                if MapAppScheme.kakaomap.isAppInstalled(),
                   let url = MapAppScheme.kakaomap.openURL() {
                    openURL(url)
                }
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    
                    Image(.kakaoMapLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("카카오맵")
                        .whereFont(.body14regular)
                        .foregroundStyle(.where(hex: 0x282828))
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.white)
                        .strokeBorder(.where(hex: 0xE3E4E9))
                )
            }
        }
    }
    
    @ViewBuilder private func pickButtonArea() -> some View {
        HStack(spacing: 16) {
            Text("이 장소로 ")
                .foregroundStyle(.black)
            + Text("Pick")
                .foregroundStyle(Color(hex: 0x4F46E5))
            + Text("할까요?")
                .foregroundStyle(.black)
            
            Spacer()
            
            Button {
                viewModel.togglePick(id: place.id)
            } label: {
                if viewModel.isTogglingProcessing {
                    ProgressView()
                } else {
                    Image(.whereCheckmark)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(isPicked ? .accent : .where(hex: 0xDEE2E6))
                        )
                }
            }
            .disabled(viewModel.isTogglingProcessing)
            .whereTip($isTipPresented, configuration: tipConfiguration) {
                Text("이 장소로 정했다면 Pick을 눌러주세요!")
                    .whereFont(.body14regular)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
        }
        .whereFont(.body16medium)
        .foregroundStyle(.black)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.where(.gray50))
        )
    }
}
