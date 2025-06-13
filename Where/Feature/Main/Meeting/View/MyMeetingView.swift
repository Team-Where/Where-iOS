//
//  MyMeetingView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI
import Swinject

struct MyMeetingView: View {
    @State private var isSideMenuPresented: Bool = false
    
    private let viewModel: MyMeetingViewModelType
    private let resolver: Resolver
    private let onLoginButtonTapped: () -> Void
    
    init(
        resolver: Resolver,
        viewModel: MyMeetingViewModelType,
        onLoginButtonTapped: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.resolver = resolver
        self.onLoginButtonTapped = onLoginButtonTapped
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Header($isSideMenuPresented, viewModel.sortType, viewModel.selectSortType)
            
            Spacer()
            
            ZStack {
                if viewModel.meetings.isEmpty {
                    UnavailableView()
                } else {
                    MeetingsView(viewModel.meetings, resolver)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.meetings.isEmpty)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(isSideMenuPresented == false)
        .sideMenu(isPresented: $isSideMenuPresented) {
            SideMenuContentView(
                $isSideMenuPresented,
                user: viewModel.user,
                meetingsCount: viewModel.meetings.count,
                resolver: resolver,
                onLoginButtonTapped: onLoginButtonTapped
            )
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

// MARK: - Subviews
private extension MyMeetingView {
    struct Header: View {
        @Binding var isSideMenuPresented: Bool
        let sortType: MeetingSortType
        let onSelectSortType: (MeetingSortType) -> Void
        
        init(
            _ isSideMenuPresented: Binding<Bool>,
            _ sortType: MeetingSortType,
            _ onSelectSortType: @escaping (MeetingSortType) -> Void
        ) {
            self._isSideMenuPresented = isSideMenuPresented
            self.sortType = sortType
            self.onSelectSortType = onSelectSortType
        }
        
        var body: some View {
            VStack {
                HStack {
                    Image("HomeLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 52, height: 24)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            isSideMenuPresented.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.black)
                    }
                }
                
                HStack(alignment: .bottom) {
                    Text("내 모임")
                        .whereFont(.title24semibold)
                    
                    Spacer()
                    
                    Menu {
                        Button("시간순") { onSelectSortType(.scheduled) }
                        Button("생성순") { onSelectSortType(.created) }
                    } label: {
                        HStack {
                            Text(sortType == .scheduled ? "시간순" : "생성순")
                            
                            Image(systemName: "chevron.down")
                                .resizable()
                                .frame(width: 8, height: 4)
                        }
                        .whereFont(.body14medium)
                        .foregroundStyle(.where(.gray700))
                    }
                }
                .padding(.top, 40)
            }
            .padding(.horizontal)
        }
    }
    
    struct UnavailableView: View {
        var body: some View {
            VStack {
                Image("HomeCharacter")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 81.45, height: 87)
                
                Text("아직 모임이 없어요")
                    .whereFont(.body16regular)
                    .foregroundStyle(Color(hex: 0xADB5BD))
                    .padding(.top, 16)
                
                NavigationLink {
                    MeetingAdditionGuideView()
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
    }
    
    struct MeetingsView: View {
        let meetings: [Meeting]
        let resolver: Resolver
        private let columns: [GridItem] = [.init(.adaptive(minimum: 120, maximum: 170))]
        
        init(
            _ meetings: [Meeting],
            _ resolver: Resolver
        ) {
            self.meetings = meetings
            self.resolver = resolver
        }
        
        var body: some View {
            ScrollView(.vertical) {
                LazyVGrid(columns: columns) {
                    ForEach(meetings) { meeting in
                        MeetingCell(meeting, resolver)
                    }
                }
            }
            .scrollIndicators(.never)
            .padding()
        }
    }
    
    struct MeetingCell: View {
        let meeting: Meeting
        let resolver: Resolver
        
        init(
            _ meeting: Meeting,
            _ resolver: Resolver
        ) {
            self.meeting = meeting
            self.resolver = resolver
        }
        
        var body: some View {
            NavigationLink {
                MeetingInformationView(resolver: resolver, meetingID: meeting.id)
            } label: {
                VStack(spacing: 12) {
                    Spacer()
                    
                    AsyncImage(url: meeting.imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 10))
                    } placeholder: {
                        Image(.defaultCover)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                    .brightness(meeting.isFinished ? -0.5 : 0)
                    .overlay {
                        if meeting.isFinished {
                            Text("종료된 모임")
                                .whereFont(.caption12regular)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 17)
                                        .fill(.accent)
                                )
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(meeting.title)
                                .whereFont(.body16medium)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            DateView(date: meeting.combinedSchedule, format: .yyyyMMdd, prompt: "등록된 일정이 없어요")
                                .whereFont(.body14regular)
                                .foregroundStyle(.where(.gray500))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .opacity(meeting.isFinished ? 0.5 : 1)
                        
                        Spacer()
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    ContentView(resolver: PreviewHelper.shared.resolver)
}
