//
//  MyMeetingView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI
import Swinject

struct MyMeetingView: View {
    @Binding var selectedTab: Int
    @Binding var isCreateMeetingSheetPresented: Bool
    @ObservedObject private var viewModel: MyMeetingViewModel
    
    private let resolver: Resolver
    
    init(
        _ selectedTab: Binding<Int>,
        _ isCreateMeetingSheetPresented: Binding<Bool>,
        resolver: Resolver
    ) {
        self._selectedTab = selectedTab
        self._isCreateMeetingSheetPresented = isCreateMeetingSheetPresented
        self.viewModel = resolver.resolve(MyMeetingViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .leading) {
                header
                
                Spacer()
                
                if viewModel.meetings.isEmpty {
                    unavailableView()
                } else {
                    meetingsSection()
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(viewModel.isSideMenuPresented == false)
            .sideMenu(isPresented: $viewModel.isSideMenuPresented) {
                SideMenuContentView($viewModel.isSideMenuPresented, resolver: resolver)
            }
        }
        .toolbar {
            if selectedTab == 0 {
                ToolbarItem(placement: .topBarLeading) {
                    Image("HomeLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 52, height: 24)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            viewModel.toggleSideMenuPresentation()
                        }
                    } label: {
                        Image(systemName: viewModel.isSideMenuPresented ? "xmark" : "line.3.horizontal")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .sheet(isPresented: $isCreateMeetingSheetPresented) {
            CreateMeetingView(resolver: resolver)
                .presentationCornerRadius(24)
                .presentationDetents([.fraction(0.99)])
        }
        .fullScreenCover(isPresented: $viewModel.isCompleteCreationViewPresented) {
            CompleteCreationView(isCompleteCreationViewPresented: $viewModel.isCompleteCreationViewPresented)
        }
    }
    
    private var header: some View {
        HStack(alignment: .bottom) {
            Text("내모임")
                .whereFont(.title24semibold)
            
            Spacer()
            
            Menu {
                Button("시간순") { viewModel.selectSortType(for: .scheduled) }
                Button("생성순") { viewModel.selectSortType(for: .created) }
            } label: {
                HStack {
                    Text(viewModel.sortType == .scheduled ? "시간순" : "생성순")
                    
                    Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: 8, height: 4)
                }
                .whereFont(.body14medium)
                .foregroundStyle(.where(.gray700))
            }
        }
        .padding(.top, 40)
        .padding(.horizontal)
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
    
    @ViewBuilder private func meetingsSection() -> some View {
        ScrollView(.vertical) {
            FlowLayout(alignment: .topLeading) {
                ForEach(viewModel.meetings) { meeting in
                    meetingCell(meeting)
                }
            }
        }
        .scrollIndicators(.never)
        .padding()
        .navigationDestination(isPresented: $viewModel.isMeetingInformationViewPresented) {
            MeetingInformationView(resolver: resolver)
        }
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
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(meeting.title)
                        .whereFont(.body16medium)
                    
                    AsyncDateView(date: .constant(nil), format: .yyyyMMdd, prompt: "등록된 일정이 없어요")
                        .whereFont(.body14regular)
                        .foregroundStyle(.where(.gray500))
                }
                .opacity(meeting.isFinished ? 0.5 : 1)
                
                Spacer()
            }
            .frame(maxWidth: 170)
        }
        .padding(.bottom, 20)
        .onTapGesture {
            viewModel.routeToMeetingInformationView(meeting: meeting)
        }
    }
}

#Preview {
    NavigationStack {
        ContentView(resolver: PreviewHelper.shared.resolver)
    }
}
