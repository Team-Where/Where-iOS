//
//  MeetingInformationView.swift
//  Where
//
//  Created by Swain Yun on 1/4/25.
//

import SwiftUI
import Swinject
import Combine

struct MeetingInformationView: View {
    @ObservedObject private var viewModel: MeetingInformationViewModel
    private let resolver: Resolver
    
    init(resolver: Resolver, meeting: Meeting) {
        self.resolver = resolver
        self.viewModel = resolver.resolve(MeetingInformationViewModel.self)!
        self.viewModel.setMeeting(meeting)
    }
    
    var body: some View {
        SelectionTab<TabViewItem>(selection: [.meetingInfo(resolver: resolver, meeting: viewModel.meeting), .placeInfo(resolver: resolver)])
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton()
                }
                
                ToolbarItem(placement: .principal) {
                    Text(viewModel.meeting.title)
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(Color(hex: 0x1F2937))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.sheetType = .editMeetingInfo
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(Color(hex: 0x1F2937))
                    }
                }
            }
            .sheet(item: $viewModel.sheetType) { type in
                switch type {
                case .editMeetingInfo:
                    EditMeetingInfoSheet (resolver: resolver)

                }
            }
    }
}

// MARK: Nested Types - CustomTabbar
extension MeetingInformationView {
    enum TabViewItem: SelectionTabItem {
        case meetingInfo(resolver: Resolver, meeting: Meeting)
        case placeInfo(resolver: Resolver)
        
        var id: Int { self.hashValue }
        
        var title: String {
            switch self {
            case .meetingInfo: "모임 정보"
            case .placeInfo: "장소"
            }
        }
        
        @ViewBuilder func view() -> some View {
            switch self {
            case .meetingInfo(let resolver, let meeting):
                MeetingInformationDetailView(meeting: meeting, resolver: resolver)
            case .placeInfo(let resolver):
                MeetingPlacesView(resolver: resolver)
            }
        }
        
        static func == (lhs: MeetingInformationView.TabViewItem, rhs: MeetingInformationView.TabViewItem) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
        }
    }
}

// MARK: Nested Types - Sheet
extension MeetingInformationView {
    
    struct EditMeetingInfoSheet: View {
        enum EditMeetingFocusState {
            case title, memo
        }
        
        @ObservedObject private var viewModel: MeetingInformationViewModel

        @FocusState private var textFieldFocused: EditMeetingFocusState?
        
        init(resolver: Resolver) {
            viewModel = resolver.resolve(MeetingInformationViewModel.self)!
        }
        
        var body: some View {
            content()
                .padding()
                .presentationCornerRadius(16)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
        
        @ViewBuilder private func content() -> some View {
            switch viewModel.editStep {
            case .entry: entry
            case .title: title
            case .memo: memo
            }
        }
        
        var entry: some View {
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x030712))
                    }
                }
                
                HStack {
                    Text(viewModel.meeting.title)
                        .whereFont(.title20semibold)
                        .foregroundStyle(Color(hex: 0x111827))
                    
                    Button {
                        viewModel.editStep = .title
                    } label: {
                        Image(.pencilIcon)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.black)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    Text(viewModel.meeting.description)
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0x6B7280))
                    Button {
                        viewModel.editStep = .memo
                    } label: {
                        Image(.pencilIcon)
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x6B7280))
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                Button {
                    // TODO: 모임 삭제(또는 나가기) 기능 연결
                } label: {
                    Text("모임에서 나가기")
                        .whereFont(.body16medium)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: 0xF3F4F6))
                        .clipShape(.rect(cornerRadius: 16))
                }
            }
            .presentationDetents([.fraction(0.3)])
        }
        
        var title: some View {
            VStack {
                HStack {
                    Text("모임 이름")
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(Color(hex: 0x1F2937))
                    
                    Spacer()
                    
                    Button {
                        textFieldFocused = .none
                        viewModel.sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x030712))
                    }
                }
                
                TextField("모임 이름 입력", text: $viewModel.titleText)
                    .whereFont(.body16regular)
                    .foregroundStyle(Color(hex: 0x1F2937))
                    .focused($textFieldFocused, equals: .title)
                
                Spacer()
                
                HStack {
                    Button {
                        textFieldFocused = .none
                        viewModel.editStep = .entry
                    } label: {
                        Text("취소")
                            .whereFont(.body16medium)
                            .foregroundColor(Color(hex: 0x4B5563))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: 0xF3F4F6))
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    
                    Button {
                        // TODO: 모임명 업데이트 기능 연결
                        textFieldFocused = .none
                        viewModel.editStep = .entry
                    } label: {
                        Text("확인")
                            .whereFont(.body16medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.accent)
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    .disabled(viewModel.titleText.isEmpty) // 모임명은 필수 입력
                }
            }
            .onAppear {
                textFieldFocused = .title
            }
            .presentationDetents(textFieldFocused == nil ? [.medium] : [.fraction(0.2)])
        }
        
        var memo: some View {
            VStack {
                HStack {
                    Text("메모")
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(Color(hex: 0x1F2937))
                    
                    Spacer()
                    
                    Button {
                        textFieldFocused = .none
                        viewModel.sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x030712))
                    }
                }
                
                TextField("메모 입력", text: $viewModel.descriptionText)
                    .whereFont(.body16regular)
                    .foregroundStyle(Color(hex: 0x1F2937))
                    .focused($textFieldFocused, equals: .memo)
                
                Spacer()
                
                HStack {
                    Button {
                        textFieldFocused = .none
                        viewModel.editStep = .entry
                    } label: {
                        Text("취소")
                            .whereFont(.body16medium)
                            .foregroundColor(Color(hex: 0x4B5563))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: 0xF3F4F6))
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    
                    Button {
                        // TODO: 메모 업데이트 기능 연결
                        textFieldFocused = .none
                        viewModel.editStep = .entry
                    } label: {
                        Text("확인")
                            .whereFont(.body16medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.accent)
                            .clipShape(.rect(cornerRadius: 16))
                    }
                }
            }
            .onAppear {
                textFieldFocused = .memo
            }
            .presentationDetents(textFieldFocused == nil ? [.medium] : [.fraction(0.2)])
        }
    }
}

//#Preview {
//    NavigationStack {
//        MeetingInformationView(resolver: PreviewHelper.shared.resolver)
//    }
//}
