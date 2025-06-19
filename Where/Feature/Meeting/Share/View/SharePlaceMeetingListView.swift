//
//  SharePlaceMeetingListView.swift
//  Where
//
//  Created by BOMBSGIE on 6/16/25.
//

import SwiftUI
import Swinject

private typealias NavigationType = SharePlaceMeetingListViewModel.NavigationType

struct SharePlaceMeetingListView: View {
    @State private var isFloaterPresented: Bool = false
    @State private var isDetailPresneted: NavigationType?
    
    private let sharedPlaceData: SharedPlaceDataSource
    private let resolver: Resolver
    private let viewModel: SharePlaceMeetingListViewModel
    private let cancellabelBag = CancellableBag()
    
    
    private let columns: [GridItem] = [.init(.adaptive(minimum: 120, maximum: 175))]
    
    init(
        dataSource: SharedPlaceDataSource,
        resolver: Resolver
    ) {
        sharedPlaceData = dataSource
        self.resolver = resolver
        viewModel = resolver.resolve(SharePlaceMeetingListViewModel.self)!
        subscribe()
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
                viewModel.addPlace(sharedPlaceData)
            } label: {
                Text("완료")
                    .frame(width: 350, height: 48)
            }
            .buttonStyle(.whereRoundedProminent(disabled: viewModel.selectedMeeting == nil))
        }
        .floater($isFloaterPresented, title: "잠시 후 다시 시도 해주세요.")
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
        }
        .navigationDestination(item: $isDetailPresneted) { type in
            switch type {
            case .detail(let meeting):
                MeetingInformationView(resolver: resolver, meetingID: meeting.id)
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

extension SharePlaceMeetingListView {
    func subscribe() {
        viewModel.floaterPublisher
            .sink {
                isFloaterPresented = $0
            }
            .store(in: cancellabelBag, key: "floater")
        viewModel.viewRouterPublisher
            .sink {
                isDetailPresneted = $0
            }
            .store(in: cancellabelBag, key: "detail")
    }
}
