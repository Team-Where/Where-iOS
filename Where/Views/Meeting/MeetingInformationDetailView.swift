//
//  MeetingInformationDetailView.swift
//  Where
//
//  Created by Swain Yun on 1/4/25.
//

import SwiftUI

struct MeetingInformationDetailView: View {
    @State private var sheetType: SheetType?
    @State private var fullScreenCoverType: FullScreenCoverType?
    @State private var navigationType: NavigationType?
    @State private var selectedDate: Date?
    
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
        .sheet(item: $sheetType) { type in
            switch type {
            case .editFriend(let friend):
                EditFriendSheet(friend: friend, sheetType: $sheetType) { friend in
                    // TODO: 모임에서 친구 삭제 기능 연결
                }
            case .sharePlace:
                SharePlaceSheet(sheetType: $sheetType)
            }
        }
        .fullScreenCover(item: $fullScreenCoverType) { type in
            switch type {
            case .editMeetingDate:
                EditMeetingDateFullScreenCover(
                    fullScreenCoverType: $fullScreenCoverType,
                    selectedDate: $selectedDate
                )
            }
        }
        .navigationDestination(item: $navigationType) { type in
            switch type {
            case .inviteFriends:
                InviteFriendsView()
            }
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
            summaryCell(.date(date: selectedDate)) {
                fullScreenCoverType = .editMeetingDate
            }
            
            summaryCell(.sharedPlace(count: 6)) {
                sheetType = .sharePlace
            }
            
            summaryCell(.invitedFriends(count: 4)) {
                navigationType = .inviteFriends
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: 0xF9FAFB))
        )
    }
    
    @ViewBuilder private func summaryCell(_ type: SummaryType, route: @escaping () -> Void) -> some View {
        HStack {
            type.content.primaryIcon
            
            switch type {
            case .date(let date):
                AsyncDateView(date: date, format: .yyyyMMddah, prompt: "아직 정해진 일정이 없어요")
                    .whereFont(.body14regular)
                    .foregroundStyle(date == .none ? Color(hex: 0x868E96) : Color(hex: 0x212529))
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
            
            Button {
                route()
            } label: {
                HStack {
                    type.content.secondaryIcon
                    
                    Text(type.content.buttonLabel)
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
                        sheetType = .editFriend(friend: friend)
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
        
        case date(date: Date?)
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
    }
}

// MARK: Sheet
extension MeetingInformationDetailView {
    /// 모임정보 상세 화면에서 라우팅 가능한 시트의 종류
    enum SheetType: Identifiable {
        /// 친구 편집
        case editFriend(friend: User)
        /// 장소 공유
        case sharePlace
        
        var id: String { String(describing: self) }
    }
    
    struct EditFriendSheet: View {
        @Binding var sheetType: SheetType?
        private let friend: User
        private let removeFriend: (User) -> Void
        
        init(
            friend: User,
            sheetType: Binding<SheetType?>,
            removeFriend: @escaping (User) -> Void
        ) {
            self.friend = friend
            self._sheetType = sheetType
            self.removeFriend = removeFriend
        }
        
        var body: some View {
            VStack {
                HStack {
                    Text("친구 편집")
                        .whereFont(.subtitle18semibold)
                    
                    Spacer()
                    
                    Button {
                        sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding()
                
                Button {
                    removeFriend(friend)
                } label: {
                    Text("모임에서 친구 삭제")
                        .whereFont(.body16medium)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: 0xF3F4F6))
                        .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal)
            }
            .presentationDetents([.fraction(0.2)])
        }
    }
    
    struct SharePlaceSheet: View {
        @Environment(\.openURL) private var openURL
        @Binding var sheetType: SheetType?
        
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
                    // TODO: 네이버지도 Universal Link 연결
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
                    // TODO: 카카오맵 Universal Link 연결
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
        }
    }
}

// MARK: FullScreenCover
extension MeetingInformationDetailView {
    /// 모임정보 상세 화면에서 라우팅 가능한 풀스크린커버의 종류
    enum FullScreenCoverType: Identifiable {
        /// 모임 일정 편집
        case editMeetingDate
        
        var id: String { String(describing: self) }
    }
    
    // MARK: 모임일정 편집 화면에서 라우팅 가능한 시트의 종류
    enum EditMeetingDateSheetType: Identifiable {
        case date, time
        
        var id: String { String(describing: self) }
    }
    
    struct EditMeetingDateFullScreenCover: View {
        @State private var sheetType: EditMeetingDateSheetType?
        @Binding var fullScreenCoverType: FullScreenCoverType?
        @State private var temporalSelectedDate: Date?
        @State private var temporalSelectedTime: Hour?
        @State private var temporalSelectedMeridiem: Meridiem?
        @Binding var selectedDate: Date?
        
        var body: some View {
            VStack(spacing: 24) {
                HStack {
                    Image(systemName: "xmark")
                        .hidden()
                    
                    Spacer()
                    
                    Text("일정 등록")
                        .whereFont(.subtitle18semibold)
                    
                    Spacer()
                    
                    Button {
                        fullScreenCoverType = .none
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .foregroundStyle(Color(hex: 0x1F2937))
                .padding(.vertical)
                
                Divider()
                
                HStack {
                    Text("만나는 날짜")
                        .whereFont(.body16medium)
                    
                    Spacer()
                    
                    Button {
                        sheetType = .date
                    } label: {
                        HStack(spacing: 8) {
                            AsyncDateView(date: $temporalSelectedDate, format: .yyyyMMddKorean, prompt: "날짜를 선택해주세요")
                                .whereFont(.body14regular)
                                .foregroundStyle(temporalSelectedDate == nil ? Color(hex: 0x6B7280) : Color(hex: 0x1F2937))
                            
                            Image(.polygonDown)
                        }
                        .foregroundStyle(Color(hex: 0x6B7280))
                        
                    }
                }
                
                Divider()
                
                HStack {
                    Text("만나는 시간")
                        .whereFont(.body16medium)
                    
                    Spacer()
                    
                    Button {
                        sheetType = .time
                    } label: {
                        HStack(spacing: 8) {
                            if let time = temporalSelectedTime,
                               let meridiem = temporalSelectedMeridiem {
                                Text("\(meridiem.description) \(time.description)")
                                    .foregroundStyle(Color(hex: 0x1F2937))
                            } else {
                                Text("시간을 선택해주세요")
                            }
                            
                            Image(.polygonDown)
                        }
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0x6B7280))
                        
                    }
                }
                
                Spacer()
                
                Button {
                    let date = temporalSelectedDate?.combine(hour: temporalSelectedTime?.rawValue, meridiem: temporalSelectedMeridiem)
                    selectedDate = date
                    fullScreenCoverType = .none
                } label: {
                    Text("확인")
                        .whereFont(.body16medium)
                        .padding()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.accent)
                        )
                }
            }
            .padding()
            .sheet(item: $sheetType) { type in
                switch type {
                case .date:
                    EditMeetingDateSheet(
                        sheetType: $sheetType,
                        selectedDate: $temporalSelectedDate
                    )
                case .time:
                    EditMeetingTimeSheet(
                        sheetType: $sheetType,
                        selectedTime: $temporalSelectedTime,
                        selectedMeridiem: $temporalSelectedMeridiem
                    )
                }
            }
        }
    }
    
    struct EditMeetingDateSheet: View {
        @Binding var sheetType: EditMeetingDateSheetType?
        @Binding var selectedDate: Date?
        @State private var temporalSelectedDate: Date?
        
        var body: some View {
            VStack(spacing: 10) {
                HStack {
                    Text("날짜 선택")
                    
                    Spacer()
                    
                    Button {
                        sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x030712))
                    }
                }
                .frame(height: 41)
                .padding([.top, .horizontal])
                
                Divider()
                
                CalendarView(selectedDate: $temporalSelectedDate)
                
                Button {
                    selectedDate = temporalSelectedDate
                    sheetType = .none
                } label: {
                    HStack {
                        AsyncDateView(date: $temporalSelectedDate, format: .MMddEEKorean, prompt: "날짜를 선택해주세요")
                        
                        if let _ = temporalSelectedDate {
                            Rectangle()
                                .frame(width: 1, height: 16)
                            
                            Text("선택")
                        }
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(temporalSelectedDate == nil ? Color(hex: 0xD1D5DB) : .accent)
                    )
                }
                .padding(.horizontal)
                .disabled(temporalSelectedDate == nil)
            }
            .presentationDetents([.fraction(0.7)])
        }
    }
    
    struct EditMeetingTimeSheet: View {
        @Binding var sheetType: EditMeetingDateSheetType?
        @Binding var selectedTime: Hour?
        @Binding var selectedMeridiem: Meridiem?
        @State private var temporalSelectedMeridiem: Meridiem = .am
        @State private var temporalSelectedTime: Hour = .one
        
        private let meridiems: [Meridiem] = Meridiem.allCases.reversed()
        private let times: [Hour] = Hour.allCases.reversed()
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("날짜 선택")
                    
                    Spacer()
                    
                    Button {
                        sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x030712))
                    }
                }
                .padding([.top, .horizontal])
                
                Divider()
                
                VStack(spacing: 23) {
                    pickerCell("오전/오후", selection: $temporalSelectedMeridiem, items: meridiems)
                    
                    Divider()
                    
                    pickerCell("시간", selection: $temporalSelectedTime, items: times)
                }
                .padding()
                
                Spacer()
                
                HStack {
                    Button {
                        sheetType = .none
                    } label: {
                        Text("취소")
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color(hex: 0x4B5563))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: 0xF3F4F6))
                    )
                    
                    Button {
                        selectedTime = temporalSelectedTime
                        selectedMeridiem = temporalSelectedMeridiem
                        sheetType = .none
                    } label: {
                        Text("확인")
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.accent)
                    )
                }
                .padding(.horizontal)
            }
            .presentationDetents([.fraction(0.54)])
        }
        
        @ViewBuilder private func pickerCell<Value: CustomStringConvertible & Hashable>(
            _ label: String,
            selection: Binding<Value>,
            items: [Value]
        ) -> some View {
            HStack {
                Text(label)
                    .whereFont(.body16medium)
                    .foregroundStyle(Color(hex: 0x495057))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Menu {
                        ForEach(items, id: \.self) { item in
                            Button {
                                selection.wrappedValue = item
                            } label: {
                                Text(item.description)
                            }
                        }
                    } label: {
                        Text(selection.wrappedValue.description)
                        
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .whereFont(.body16semibold)
                    .foregroundStyle(Color(hex: 0x212529))
                }
            }
        }
    }
}

// MARK: NavigationType
extension MeetingInformationDetailView {
    /// 모임정보 상세 화면에서 라우팅 가능한 네비게이션패스의 종류
    enum NavigationType: Hashable {
        /// 친구 초대
        case inviteFriends
    }
}

#Preview {
    NavigationStack {
        MeetingInformationDetailView()
    }
}
