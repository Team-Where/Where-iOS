//
//  MeetingInformationDetailView.swift
//  Where
//
//  Created by Swain Yun on 1/4/25.
//

import SwiftUI

struct MeetingInformationDetailView: View {
    var body: some View {
        ScrollView(.vertical) {
            header
                .padding()
            
            summaryArea
                .padding(.bottom)
                .padding(.horizontal)
            
            friendsList([
                .init(nickname: "나", isFavorite: false),
                .init(nickname: "죠니월드", isFavorite: false),
                .init(nickname: "이초홍", isFavorite: false),
                .init(nickname: "랄랄", isFavorite: false),
            ], isInvited: true)
            .padding(.bottom)
            .padding(.horizontal)
            
            friendsList([
                .init(nickname: "두니주니", isFavorite: true)
            ], isInvited: false)
            .padding(.bottom)
            .padding(.horizontal)
        }
    }
    
    private var header: some View {
        HStack {
            AsyncImage(url: nil)
                .frame(width: 64, height: 64)
                .clipShape(.rect(cornerRadius: 12))
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("2024 연말파티")
                    .whereFont(.title20semibold)
                    .foregroundStyle(Color(hex: 0x111827))
                
                Text("벌써 연말이다 신나게 놀아보장~~")
                    .whereFont(.body14regular)
            }
            .foregroundStyle(Color(hex: 0x6B7280))
            
            Spacer()
        }
    }
    
    private var summaryArea: some View {
        VStack(spacing: 8) {
            SummaryType.date(date: .now).view()
            
            SummaryType.sharedPlace(count: 6).view()
            
            SummaryType.invitedFriends(count: 4).view()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: 0xF9FAFB))
        )
    }
    
    @ViewBuilder private func friendsList(_ friends: [User], isInvited: Bool) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(isInvited ? "초대된 친구" : "수락을 기다리는 친구")
                    .whereFont(.body16semibold)
                    .foregroundStyle(Color(hex: 0x1F2937))
                
                Spacer()
            }
            
            Divider()
            
            ForEach(friends) { friend in
                HStack {
                    AsyncImage(url: friend.imageURL)
                        .frame(width: 40, height: 40)
                        .clipShape(.circle)
                    
                    Text(friend.nickname)
                        .whereFont(.body16medium)
                        .foregroundStyle(Color(hex: 0x374151))
                    
                    Spacer()
                    
                    Button {
                        // TODO: 친구 편집 기능 연결
                    } label: {
                        if isInvited {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(Color(hex: 0x868E96))
                        } else {
                            Text("대기중")
                                .whereFont(.caption12regular)
                                .foregroundStyle(Color(hex: 0x6B7280))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 26)
                                        .fill(Color(hex: 0xF3F4F6))
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .strokeBorder(Color(hex: 0xF3F4F6))
                .shadow(color: Color(hex: 0x566271).opacity(0.1), radius: 1, y: 4)
        )
    }
}

// MARK: Nested Types
extension MeetingInformationDetailView {
    enum SummaryType: Identifiable {
        typealias Content = (primaryIcon: Image, secondaryIcon: Image, buttonLabel: String)
        
        case date(date: Date)
        case sharedPlace(count: UInt)
        case invitedFriends(count: UInt)
        
        var id: String { String(describing: self) }
        
        var content: Content {
            switch self {
            case .date:
                (
                    Image(.colorCalendarIcon),
                    Image(.calendarIcon),
                    "일정 등록"
                )
            case .sharedPlace:
                (
                    Image(.colorSharedPlaceMarkerIcon),
                    Image(.addPlusCircleIcon),
                    "장소 공유"
                )
            case .invitedFriends:
                (
                    Image(.colorInvitedFriendsIcon),
                    Image(.addUserIcon),
                    "친구 초대"
                )
            }
        }
        
        @ViewBuilder func view() -> some View {
            HStack {
                content.primaryIcon
                
                switch self {
                case .date(let date):
                    AsyncDateView(date: date, format: .yyyyMMddah, prompt: "아직 정해진 일정이 없어요")
                case .sharedPlace(let count):
                    HStack {
                        Text("공유된 장소")
                            .whereFont(.body14regular)
                            .foregroundStyle(Color(hex: 0x212529))
                        
                        Text("\(count)")
                            .whereFont(.body14semibold)
                            .foregroundStyle(.accent)
                    }
                case .invitedFriends(let count):
                    HStack {
                        Text("초대된 친구")
                            .whereFont(.body14regular)
                            .foregroundStyle(Color(hex: 0x212529))
                        
                        Text("\(count)")
                            .whereFont(.body14semibold)
                            .foregroundStyle(.accent)
                    }
                }
                
                Spacer()
                
                HStack {
                    content.secondaryIcon
                    
                    Text(content.buttonLabel)
                        .whereFont(.caption12regular)
                        .foregroundStyle(Color(hex: 0x212529))
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                        .strokeBorder(Color(hex: 0xE5E7EB))
                )
            }
        }
    }
}

#Preview {
    MeetingInformationDetailView()
}
