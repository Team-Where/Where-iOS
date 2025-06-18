//
//  SharePlaceMeetingListView.swift
//  Where
//
//  Created by BOMBSGIE on 6/16/25.
//

import SwiftUI
import Swinject

struct SharePlaceMeetingListView: View {
    @State private var isPresented: Bool = false

    
    private let placeName: String
    private let placeURL: String
    private let viewModel: SharePlaceMeetingListViewModel

    private let columns: [GridItem] = [.init(.adaptive(minimum: 120, maximum: 175))]
    
    init(
        placeName: String,
        placeURL: String,
        resolver: Resolver
    ) {
        self.placeName = placeName
        self.placeURL = placeURL
        viewModel = resolver.resolve(SharePlaceMeetingListViewModel.self)!
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            Text("장소를 공유할\n모임을 선택해주세요")
                .whereFont(.title24semibold)
                .padding(.bottom)
            ScrollView(.vertical) {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.meetings) { meeting in
                        MeetingCell(viewModel: viewModel, meeting: meeting)
                    }
                }
            }
            
            Button {
                //TODO: View이동
            } label: {
                Text("완료")
                    .frame(width: 350, height: 48)
            }
            .buttonStyle(.whereRoundedProminent(disabled: viewModel.selectedMeeting == nil))
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
        }
    }
}

extension SharePlaceMeetingListView {
    struct MeetingCell: View {
        private let viewModel: SharePlaceMeetingListViewModel
        private let meeting: Meeting
        
        init(
            viewModel: SharePlaceMeetingListViewModel,
            meeting: Meeting
        ) {
            self.viewModel = viewModel
            self.meeting = meeting
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                AsyncImage(url: nil) { image in
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
                .overlay {
                    if viewModel.selectedMeeting == meeting {
                        RoundedRectangle(cornerRadius: 10)
                            .opacity(0.6)
                        Image(.whereCheckmark)
                            .background {
                                Circle()
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(.accent)
                            }
                    }
                }
                Text(meeting.title)
                    .whereFont(.body16regular)
                Text(meeting.scheduleDate?.toString() ?? "아직 정해진 일정이 없습니다.")
                    .whereFont(.body14regular)
            }
            .onTapGesture {
                viewModel.select(meeting: meeting)
            }
        }
    }
}
