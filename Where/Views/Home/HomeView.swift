//
//  HomeView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage(AppStorageKey.isOnboardingNeeded) private var isOnboardingNeeded: Bool = true
    @Binding var selectedTab: Int
    @State private var isOnboardingViewPresented: Bool = false
    @State private var isSideMenuPresented: Bool = false
    @State private var meetings: [Meeting] = []
    
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .leading) {
                Text("내모임")
                    .whereFont(.title24semibold)
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                Spacer()
                
                if meetings.isEmpty {
                    unavailableView()
                } else {
                    meetingsSection()
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(isSideMenuPresented == false)
            .sideMenu(isPresented: $isSideMenuPresented) {
                SideMenuContentView(isSideMenuPresented: $isSideMenuPresented)
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
                            isSideMenuPresented.toggle()
                        }
                    } label: {
                        Image(systemName: isSideMenuPresented ? "xmark" : "line.3.horizontal")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .onAppear {
            isOnboardingViewPresented = isOnboardingNeeded
        }
        .navigationDestination(isPresented: $isOnboardingViewPresented) {
            OnboardingView()
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
            
            NavigationLink {
                HowToAddMeetingView()
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
                ForEach(meetings) { meeting in
                    meetingCell(meeting)
                }
            }
        }
        .scrollIndicators(.never)
        .padding()
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
        .padding(.bottom, 20)
    }
}

#Preview {
    TabBarView()
}
