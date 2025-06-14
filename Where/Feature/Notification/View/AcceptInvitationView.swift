//
//  AcceptInvitationView.swift
//  Where
//
//  Created by Swain Yun on 4/30/25.
//

import SwiftUI
import Swinject

struct AcceptInvitationView: View {
    private let inviterName: String?
    private let meeting: Meeting?
    
    private let viewModel: AcceptInvitationViewModel
    
    init(
        inviterName: String?,
        meeting: Meeting?,
        resolver: Resolver
    ) {
        self.inviterName = inviterName
        self.meeting = meeting
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
            
            Text("\(inviterName ?? "-")님이 초대합니다")
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
                    viewModel.acceptInvitation()
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
            AsyncImage(url: meeting?.imageURL) { image in
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
                            .frame(width: 69.38, height: 56.54)
                    }
            }
            
            VStack(spacing: 12) {
                Text(meeting?.title ?? "-")
                    .whereFont(.title24semibold)
                    .foregroundStyle(.where(.gray900))
                
                HStack(spacing: 4) {
                    Image(.calendarIcon)
                    
                    Text(meeting?.scheduleDate?.toString(by: .yyyyMMdd) ?? "아직 정해진 일정이 없어요")
                    
                    Text(meeting?.scheduleTime?.toString(by: .ahmm) ?? "")
                }
                .whereFont(.body14regular)
                .foregroundStyle(.where(.gray700))
            }
        }
    }
}
