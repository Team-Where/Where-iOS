//
//  AcceptInvitationView.swift
//  Where
//
//  Created by Swain Yun on 4/30/25.
//

import SwiftUI
import Swinject

struct AcceptInvitationView: View {
    @ObservedObject private var viewModel: AcceptInvitationViewModel
    
    init(resolver: Resolver) {
        viewModel = resolver.resolve(AcceptInvitationViewModel.self)!
    }
    
    var body: some View {
        VStack {
            particleArea
            
            invitationBoxArea
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("알림")
                    .whereFont(.title24semibold)
                    .foregroundStyle(.where(.gray800))
            }
        }
    }
    
    private var particleArea: some View {
        ZStack(alignment: .bottom) {
            Image(.particle)
            // TODO: 하드코딩 정리하기
            Text("김현영님이 초대합니다")
                .whereFont(.body16regular)
                .foregroundStyle(.where(.gray800))
        }
        .padding(.bottom)
    }
    
    private var invitationBoxArea: some View {
        VStack(spacing: 10) {
            VStack(spacing: 24) {
                invitationInfoArea
                
                Button {
                    // TODO: 수락하기 기능 연결
                } label: {
                    Text("수락하기")
                        .whereFont(.body16semibold)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 350, height: 386)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.clear)
                .strokeBorder(.where(hex: 0xE5E7EB))
        )
    }
    
    private var invitationInfoArea: some View {
        VStack(spacing: 16) {
            // TODO: 실제 데이터 주입
            AsyncImage(url: viewModel.meeting.imageURL) { image in
                image
                    .frame(width: 120, height: 120)
                    .clipShape(.buttonBorder)
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.where(hex: 0xD9D9D9))
                    .frame(width: 120, height: 120)
                    .overlay {
                        Image(.logoShortWhite)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 89)
                    }
            }
            
            VStack(spacing: 12) {
                Text(viewModel.meeting.title)
                    .whereFont(.title24semibold)
                    .foregroundStyle(.where(.gray900))
                
                HStack(spacing: 4) {
                    Image(.calendarIcon)
                    
                    Text("2024.12.28")
                    
                    Text("오후 5시")
                }
                .whereFont(.body14regular)
                .foregroundStyle(.where(.gray700))
            }
        }
    }
}

#Preview {
    NavigationStack {
        AcceptInvitationView(resolver: PreviewHelper.shared.resolver)
    }
}
