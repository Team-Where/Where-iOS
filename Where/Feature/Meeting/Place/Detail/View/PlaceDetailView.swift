//
//  PlaceDetailView.swift
//  Where
//
//  Created by 이현호 on 1/18/25.
//

import SwiftUI
import Swinject

struct PlaceDetailView: View {
    @ObservedObject private var viewModel: PlaceDetailViewModel
    
    private let tipConfiguration = ToolTipConfiguration(arrowPosition: .topTrailing, backgroundColor: .accent, cornerRadius: 4)
    private let resolver: Resolver
    
    private let place = Place(id: 0, userId: 0, meetingId: 0, name: "무드서울", address: "서울 용산구 한강대로21길 18 1층", createdAt: .now, updatedAt: .now, likesCount: 1, pickedState: .unpicked, comments: [.init(placeId: 0, description: "여기 웨이팅있어서 미리 예약하고 가는게 좋을 듯", writerId: 0, createdAt: .now, updatedAt: .now), .init(placeId: 0, description: "야경 맛집임", writerId: 1, createdAt: .now, updatedAt: .now)], isSimulaneouslyPicked: true)
    
    init(resolver: Resolver) {
        self.viewModel = resolver.resolve(PlaceDetailViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                placeInfoArea(place)
                
                mapButtonsArea
                
                pickButtonArea()
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.presentDeletionSheet()
                    } label: {
                        Text("삭제")
                            .whereFont(.body16medium)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isDeletionSheetPresented) {
                PlaceDelete()
                    .presentationDetents([.height(148)])
                    .presentationCornerRadius(16)
            }
            
            VStack {
                Rectangle()
                    .foregroundStyle(Color(hex: 0xF1F3F5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 8)
                    .padding(.vertical, 32)
            }
            
            CommentView()
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    @ViewBuilder private func placeInfoArea(_ place: Place) -> some View {
        VStack(spacing: 12) {
            VStack(spacing :4) {
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
                    
                    Text(place.comments.count > 0 ? "코멘트 \(place.comments.count)" : "코멘트")
                }
                .foregroundStyle(.where(hex: 0x868E96))
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                    
                    Text(place.likesCount > 0 ? "좋아요 \(place.likesCount)" : "좋아요")
                }
                .foregroundStyle(place.likesCount > 0 ? .accent : .where(hex: 0x868E96))
            }
            .whereFont(.body14medium)
        }
    }
    
    private var mapButtonsArea: some View {
        HStack(spacing: 8) {
            Button {
                // TODO: 네이버 지도 열기
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
                // TODO: 카카오맵 열기
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
                viewModel.togglePick()
            } label: {
                Image(.whereCheckmark)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(viewModel.isPicked ? .accent : .where(hex: 0xDEE2E6))
                    )
            }
            .whereTip($viewModel.isTipPresented, configuration: tipConfiguration) {
                Text("이 장소로 정했다면 Pick을 눌러주세요!")
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

#Preview {
    NavigationStack {
        PlaceDetailView(resolver: PreviewHelper.shared.resolver)
    }
}
