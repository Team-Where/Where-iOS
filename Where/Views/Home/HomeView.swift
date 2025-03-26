//
//  HomeView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI

struct HomeView: View {
    @State private var meetings: [Meeting] = [
        .init(id: 0, title: "퇴근 후 치맥 번개 🍻", description: "오늘 하루 고생한 당신, 시원한 맥주와 치킨으로 스트레스 날려봐요!", link: URL(string: "https://example.com/chimaek")!, imageURL: URL(string: "https://via.placeholder.com/150/FFC107/000000?Text=Chimaek")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 1, title: "주말 한강 피크닉 돗자리 🌸", description: "이번 주말, 돗자리 펴고 맛있는 음식과 함께 여유로운 시간을 보내요!", link: URL(string: "https://example.com/hangang")!, imageURL: URL(string: "https://via.placeholder.com/150/4CAF50/FFFFFF?Text=Picnic")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 2, title: "새로운 취미 만들기 - 뜨개질 클래스 🧶", description: "따뜻한 겨울, 함께 뜨개질하며 나만의 작품을 만들어 볼까요?", link: URL(string: "https://example.com/knitting")!, imageURL: URL(string: "https://via.placeholder.com/150/F44336/FFFFFF?Text=Knitting")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 3, title: "인기 보드게임 번개 모임 🎲", description: "스플렌더, 코드네임 등 재미있는 보드게임을 함께 즐겨요! 초보 환영!", link: URL(string: "https://example.com/boardgame")!, imageURL: URL(string: "https://via.placeholder.com/150/3F51B5/FFFFFF?Text=Boardgame")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 4, title: "퇴근 후 영화 감상 모임 🎬", description: "최신 개봉작 함께 보고, 영화에 대한 이야기도 나눠봐요!", link: URL(string: "https://example.com/movie")!, imageURL: URL(string: "https://via.placeholder.com/150/9C27B0/FFFFFF?Text=Movie")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 5, title: "동네 맛집 탐방 - 쌀국수 🍜", description: "숨겨진 동네 쌀국수 맛집을 함께 찾아 떠나볼까요?", link: URL(string: "https://example.com/ricenoodle")!, imageURL: URL(string: "https://via.placeholder.com/150/FF9800/FFFFFF?Text=Ricenoodle")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 6, title: "가볍게 뛰어요! 아침 조깅 🏃‍♀️", description: "상쾌한 아침 공기를 마시며 함께 조깅해요! 건강한 하루 시작!", link: URL(string: "https://example.com/jogging")!, imageURL: URL(string: "https://via.placeholder.com/150/8BC34A/FFFFFF?Text=Jogging")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 7, title: "주말 근교 드라이브 🚗", description: "답답한 도시를 벗어나 근교로 드라이브 떠나요! 멋진 풍경 감상!", link: URL(string: "https://example.com/drive")!, imageURL: URL(string: "https://via.placeholder.com/150/2196F3/FFFFFF?Text=Drive")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 8, title: "함께 만들어요! 베이킹 클래스 🍰", description: "달콤한 케이크나 쿠키를 함께 만들며 즐거운 시간을 가져봐요!", link: URL(string: "https://example.com/baking")!, imageURL: URL(string: "https://via.placeholder.com/150/E91E63/FFFFFF?Text=Baking")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 9, title: "일상 속 힐링 - 요가 & 명상 🙏", description: "지친 몸과 마음을 달래줄 요가와 명상으로 편안한 시간을 가져봐요.", link: URL(string: "https://example.com/yoga")!, imageURL: URL(string: "https://via.placeholder.com/150/673AB7/FFFFFF?Text=Yoga")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 10, title: "퇴근 후 간단한 스터디 모임 📚", description: "관심 있는 분야 함께 공부하고 정보 공유해요!", link: URL(string: "https://example.com/study")!, imageURL: URL(string: "https://via.placeholder.com/150/607D8B/FFFFFF?Text=Study")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 11, title: "주말 미술관 나들이 🎨", description: "다양한 작품 감상하며 예술적인 영감을 얻어봐요!", link: URL(string: "https://example.com/artmuseum")!, imageURL: URL(string: "https://via.placeholder.com/150/009688/FFFFFF?Text=ArtMuseum")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 12, title: "신나는 음악과 함께! 댄스 클래스 💃", description: "스트레스 해소에 최고! 함께 춤추며 즐거운 시간 보내요!", link: URL(string: "https://example.com/dance")!, imageURL: URL(string: "https://via.placeholder.com/150/795548/FFFFFF?Text=Dance")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 13, title: "향긋한 커피와 함께하는 독서 모임 ☕", description: "좋은 책 함께 읽고, 서로의 생각을 나누는 시간을 가져봐요.", link: URL(string: "https://example.com/bookclub")!, imageURL: URL(string: "https://via.placeholder.com/150/A1887F/FFFFFF?Text=BookClub")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 14, title: "퇴근 후 온라인 게임 같이 해요 🎮", description: "함께 롤, 배그 등 온라인 게임 즐기면서 스트레스 풀어요!", link: URL(string: "https://example.com/gaming")!, imageURL: URL(string: "https://via.placeholder.com/150/9E9E9E/FFFFFF?Text=Gaming")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 15, title: "주말 등산으로 건강 챙기기 ⛰️", description: "맑은 공기 마시며 함께 등산하고 멋진 풍경도 감상해요!", link: URL(string: "https://example.com/hiking")!, imageURL: URL(string: "https://via.placeholder.com/150/689F38/FFFFFF?Text=Hiking")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 16, title: "나만의 향수 만들기 워크숍 💐", description: "특별한 나만의 향수를 직접 만들어 보세요!", link: URL(string: "https://example.com/perfume")!, imageURL: URL(string: "https://via.placeholder.com/150/FFEB3B/FFFFFF?Text=Perfume")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 17, title: "퇴근 후 외국어 회화 스터디 (영어) 🗣️", description: "함께 영어로 대화하며 회화 실력을 향상시켜 봐요!", link: URL(string: "https://example.com/english")!, imageURL: URL(string: "https://via.placeholder.com/150/03A9F4/FFFFFF?Text=English")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 18, title: "주말 캠핑 & 바베큐 파티 🔥", description: "자연 속에서 맛있는 바베큐와 함께 잊지 못할 추억을 만들어요!", link: URL(string: "https://example.com/camping")!, imageURL: URL(string: "https://via.placeholder.com/150/795548/FFFFFF?Text=Camping")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 19, title: "함께 떠나요! 자전거 라이딩 🚴", description: "시원한 바람을 맞으며 함께 자전거 타고 달려봐요!", link: URL(string: "https://example.com/biking")!, imageURL: URL(string: "https://via.placeholder.com/150/CDDC39/FFFFFF?Text=Biking")!, createdAt: .now, updatedAt: .now, schedule: .now),
        .init(id: 20, title: "새로운 맛집 도전! 인도 음식 🍛", description: "색다른 인도 음식 맛집을 함께 탐험해 볼까요?", link: URL(string: "https://example.com/indianfood")!, imageURL: URL(string: "https://via.placeholder.com/150/FF5722/FFFFFF?Text=IndianFood")!, createdAt: .now, updatedAt: .now, schedule: .now)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("내모임")
                .whereFont(.title24semibold)
                .padding(.top, 40)
            
            Spacer()
            
            if meetings.isEmpty {
                unavailableView()
            } else {
                meetingsSection()
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image("HomeLogo")
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // 햄버거 메뉴
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.black)
                }
            }
        }
    }
    
    @ViewBuilder private func unavailableView() -> some View {
        VStack {
            Image("HomeCharacter")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 81.45, height: 87)
            
            Text("아직 모임이 없어요")
                .whereFont(.body16regular)
                .foregroundStyle(Color(hex: 0xADB5BD))
                .padding(.top, 16)
            
            Button {
                
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 144, height: 40)
                        .padding(.horizontal)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .whereFont(.body16regular)
                            .foregroundStyle(Color(hex: 0x4F46E5))
                        
                        Text("모임 추가 방법")
                            .whereFont(.body16regular)
                            .foregroundStyle(Color(hex: 0x4F46E5))
                    }
                }
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private func meetingsSection() -> some View {
        ScrollView(.vertical) {
//            FlowLayout(alignment: .topLeading) {
//                ForEach(meetings) { meeting in
//                    meetingCell(meeting)
//                }
//            }
            
            LazyVGrid(columns: [.init(), .init()]) {
                ForEach(meetings) { meeting in
                    meetingCell(meeting)
                }
            }
        }
        .scrollIndicators(.never)
    }
    
    @ViewBuilder private func meetingCell(_ meeting: Meeting) -> some View {
        VStack(spacing: 12) {
            AsyncImage(url: meeting.imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 10))
                    .frame(width: 170, height: 170)
            } placeholder: {
                Image(.defaultCover)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 10))
                    .frame(width: 170, height: 170)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(meeting.title)
                        .whereFont(.body16medium)
                    
                    AsyncDateView(date: .constant(meeting.schedule), format: .yyyyMMdd, prompt: String())
                        .whereFont(.body14regular)
                        .foregroundStyle(.where(.gray500))
                }
                
                Spacer()
            }
            .frame(maxWidth: 170)
        }
        .padding(.top, 20)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
