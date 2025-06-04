//
//  CreateMeetingView.swift
//  Where
//
//  Created by Swain Yun on 3/27/25.
//

import SwiftUI
import Swinject

fileprivate typealias MeetingCreationStep = CreateMeetingViewModel.MeetingCreationStep
fileprivate typealias FloaterItem = CreateMeetingViewModel.FloaterItem
fileprivate typealias FriendCellDataSource = CreateMeetingViewModel.FriendCellDataSource


struct CreateMeetingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateMeetingViewModel
    
    @Binding private var sheetType: MainSheetType?
    @Binding private var fullScreenCoverType: MainFullScreenCoverType?
    
    private let resolver: Resolver
    
    init(
        resolver: Resolver,
        sheetType: Binding<MainSheetType?>,
        fullScreenCoverType: Binding<MainFullScreenCoverType?>
    ) {
        self._viewModel = StateObject(wrappedValue: resolver.resolve(CreateMeetingViewModel.self)!)
        self.resolver = resolver
        self._sheetType = sheetType
        self._fullScreenCoverType = fullScreenCoverType
    }

    var body: some View {
        VStack {
            dismissButton
            
            Spacer()
            
            header
            content(viewModel.step)
                .padding(.top)
            
            Spacer()
        }
        .padding()
        .popup($viewModel.isPopupPresented) {
            ImageSelectionPopupView(isPopupPresented: $viewModel.isPopupPresented) { imageData in
                viewModel.selectedImage = imageData
            }
        }
        .onAppear {
            viewModel.viewRoutingPublisher
                .sink {
                    sheetType = $0.sheet
                    fullScreenCoverType = $0.cover
                }
                .store(in: viewModel.cancellableBag, key: #function)
        }
    }
    
    private var dismissButton: some View {
        HStack {
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.where(.gray800))
            }
        }
        .padding(.top)
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("새 모임 만들기(\(viewModel.step.turn)/2)")
                    .whereFont(.body14medium)
                    .foregroundStyle(.accent)
                
                Text(viewModel.step.navigationTitle)
                    .whereFont(.title24semibold)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder private func content(_ step: MeetingCreationStep) -> some View {
        switch step {
        case .basicInformation:
            BasicInformationView(viewModel: viewModel)
        case .inviteFriends:
            InvitationView(viewModel: viewModel)
        }
    }
}

// MARK: Subviews
extension CreateMeetingView {
    struct BasicInformationView: View {
        struct Constants {
            static let titleCharacterLimit: Int = 16
            static let descriptionCharacterLimit: Int = 30
        }
        
        private enum TextFieldFocusState {
            case title, description
        }
        
        @ObservedObject private var viewModel: CreateMeetingViewModel
        @FocusState private var isFocused: TextFieldFocusState?
        
        init(viewModel: CreateMeetingViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 40) {
                        profileImageSection
                        textFieldSection
                    }
                }
                .floater($viewModel.isFloaterPresented, title: "모임 이름과 사진은 생성 후에도 변경할 수 있어요.")
                
                Button {
                    viewModel.setBasicInfo()
                } label: {
                    Text("다음")
                        .whereFont(.body16medium)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.whereRoundedProminent(disabled: viewModel.disabled))
            }
            .clipShape(.rect)
            .onTapGesture {
                isFocused = nil
            }
            .onAppear {
                viewModel.isFloaterPresented = true
            }
        }
        
        private var profileImageSection: some View {
            Button {
                withAnimation {
                    viewModel.isPopupPresented = true
                }
            } label: {
                if viewModel.isImageSelected == false {
                    VStack {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .foregroundStyle(.where(.gray600))
                        
                        Text("사진 추가")
                            .whereFont(.body14medium)
                            .foregroundStyle(.where(.gray600))
                    }
                    .frame(width: 120, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.where(.gray100))
                    )
                } else {
                    if let data = viewModel.selectedImage,
                       let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .rounded(contentMode: .fill, width: 120, height: 120, cornerRadius: 16)
                    } else {
                        Image(.person)
                            .resizable()
                            .rounded(contentMode: .fill, width: 120, height: 120, cornerRadius: 16)
                    }
                }
            }
        }
        
        @ViewBuilder private var textFieldSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    TextField(
                        "",
                        text: $viewModel.titleFieldText,
                        prompt: Text(verbatim: "모임이름을 입력해주세요")
                            .foregroundStyle(.where(.gray600))
                    )
                    .characterLimit(text: $viewModel.titleFieldText, limit: Constants.titleCharacterLimit)
                    .focused($isFocused, equals: .title)
                    
                    if viewModel.titleFieldText.isEmpty == false {
                        Button {
                            viewModel.titleFieldText.removeAll()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 15.83, height: 15.83)
                                .foregroundStyle(.where(.gray500))
                        }
                    }
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(isFocused == .title ? .accent : .where(.gray200))
                
                Text("(\(viewModel.titleFieldText.count)/\(Constants.titleCharacterLimit))")
                    .foregroundStyle(.where(.gray700))
            }
            .whereFont(.body16regular)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    TextField(
                        "",
                        text: $viewModel.descriptionFieldText,
                        prompt: Text(verbatim: "모임에 대한 간단한 소개를 입력해주세요")
                            .foregroundStyle(.where(.gray600))
                    )
                    .characterLimit(text: $viewModel.descriptionFieldText, limit: Constants.descriptionCharacterLimit)
                    .focused($isFocused, equals: .description)
                    
                    if viewModel.descriptionFieldText.isEmpty == false {
                        Button {
                            viewModel.descriptionFieldText.removeAll()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 15.83, height: 15.83)
                                .foregroundStyle(.where(.gray500))
                        }
                    }
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(isFocused == .description ? .accent : .where(.gray200))
                
                Text("(\(viewModel.descriptionFieldText.count)/\(Constants.descriptionCharacterLimit))")
                    .foregroundStyle(.where(.gray700))
            }
            .whereFont(.body16regular)
        }
    }
    
    struct InvitationView: View {
        @ObservedObject private var viewModel: CreateMeetingViewModel
        
        init(viewModel: CreateMeetingViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack {
                ScrollView(.vertical) {
                    friendsSections(viewModel.friendsDataSource)
                }
                .scrollIndicators(.never)
                .floater($viewModel.floaterItem) { _ in
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                }
                
                Button {
                    viewModel.setInvitedFriends()
                    viewModel.createMeeting()
                } label: {
                    Text("다음")
                        .whereFont(.body16medium)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.whereRoundedProminent())
            }
        }
        
        @ViewBuilder private func friendsSections(_ friends: [FriendCellDataSource]) -> some View {
            Section {
                LazyVStack(spacing: 16) {
                    ForEach(friends.filter { $0.isRecent }) { friend in
                        Cell(viewModel, friend: friend)
                    }
                }
            } header: {
                HStack {
                    Text("최근 만난 친구")
                        .whereFont(.body14semibold)
                        .foregroundStyle(.where(.gray700))
                    
                    Spacer()
                }
            }
            .padding(.top)
            
            Section {
                LazyVStack(spacing: 16) {
                    ForEach(friends) { friend in
                        Cell(viewModel, friend: friend)
                    }
                }
            } header: {
                HStack {
                    Text("친구 \(friends.count)")
                        .whereFont(.body14semibold)
                        .foregroundStyle(.where(.gray700))
                    
                    Spacer()
                }
            }
            .padding(.top)
        }
    }
}

// MARK: Nested Types
extension CreateMeetingView.InvitationView {
    struct Cell: View {
        @ObservedObject private var viewModel: CreateMeetingViewModel
        
        fileprivate let dataSource: FriendCellDataSource
        
        private var isSelected: Bool {
            viewModel.selectedParticipantIDs.contains(dataSource.id)
        }
        
        fileprivate init(
            _ viewModel: CreateMeetingViewModel,
            friend: FriendCellDataSource
        ) {
            self.viewModel = viewModel
            self.dataSource = friend
        }
        
        var body: some View {
            HStack(spacing: 12) {
                AsyncImage(url: dataSource.friend.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(.circle)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                        .clipShape(.circle)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dataSource.friend.nickname)
                        .whereFont(.body16medium)
                        .foregroundStyle(.where(.gray800))
                    
                    Text("\(dataSource.meetingCount)번 만남")
                        .whereFont(.caption11regular)
                        .foregroundStyle(.where(.gray400))
                }
                
                Spacer()
                
                Button {
                    viewModel.toggleInvitationState(for: dataSource.id)
                } label: {
                    inviteButtonLabel()
                        .whereFont(.body14medium)
                        .foregroundStyle(.accent)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? .where(hex: 0xF1F3F5) : .white)
                                .strokeBorder(.where(hex: 0xDEE2E6))
                                .frame(width: isSelected ? 72 : 52, height: 32)
                        )
                }
            }
        }
        
        @ViewBuilder private func inviteButtonLabel() -> some View {
            if isSelected {
                HStack {
                    Image(systemName: "checkmark")
                    
                    Text("완료")
                }
            } else {
                Text("초대")
            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        CreateMeetingView(resolver: PreviewHelper.shared.resolver)
//    }
//}
