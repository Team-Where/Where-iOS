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
    @Binding private var sheetType: MainSheetType?
    @Binding private var fullScreenCoverType: MainFullScreenCoverType?
    @State private var isPopupPresented: Bool = false
    @State private var selectedImageData: Data?
    
    private let viewModel: CreateMeetingViewModel
    private let resolver: Resolver
    
    init(
        resolver: Resolver,
        sheetType: Binding<MainSheetType?>,
        fullScreenCoverType: Binding<MainFullScreenCoverType?>
    ) {
        self.viewModel = resolver.resolve(CreateMeetingViewModel.self)!
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
        .popup($isPopupPresented) {
            ImageSelectionPopupView(isPopupPresented: $isPopupPresented) { imageData in
                selectedImageData = imageData
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
            BasicInformationView($isPopupPresented, $selectedImageData, viewModel)
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
        
        @Binding var isPopupPresented: Bool
        @Binding var imageData: Data?
        @FocusState private var isFocused: TextFieldFocusState?
        @State private var isFloaterPresented: Bool = false
        @State private var titleFieldText = String()
        @State private var descriptionFieldText = String()
        
        private var disabled: Bool { titleFieldText.isEmpty }
        
        private let viewModel: BasicInformationPerformable
        
        init(
            _ isPopupPresented: Binding<Bool>,
            _ selectedImageData: Binding<Data?>,
            _ viewModel: BasicInformationPerformable
        ) {
            self._isPopupPresented = isPopupPresented
            self._imageData = selectedImageData
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
                .floater($isFloaterPresented, title: "모임 이름과 사진은 생성 후에도 변경할 수 있어요.")
                
                Button {
                    viewModel.setBasicInfo(title: titleFieldText, description: descriptionFieldText, imageData: imageData)
                } label: {
                    Text("다음")
                        .whereFont(.body16medium)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.whereRoundedProminent(disabled: disabled))
            }
            .clipShape(.rect)
            .onTapGesture { isFocused = nil }
            .onAppear { isFloaterPresented = true }
        }
        
        private var profileImageSection: some View {
            Button {
                withAnimation {
                    isPopupPresented = true
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
                    if let data = imageData,
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
                        text: $titleFieldText,
                        prompt: Text(verbatim: "모임이름을 입력해주세요")
                            .foregroundStyle(.where(.gray600))
                    )
                    .characterLimit(text: $titleFieldText, limit: Constants.titleCharacterLimit)
                    .focused($isFocused, equals: .title)
                    
                    if titleFieldText.isEmpty == false {
                        Button {
                            titleFieldText.removeAll()
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
                
                Text("(\(titleFieldText.count)/\(Constants.titleCharacterLimit))")
                    .foregroundStyle(.where(.gray700))
            }
            .whereFont(.body16regular)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    TextField(
                        "",
                        text: $descriptionFieldText,
                        prompt: Text(verbatim: "모임에 대한 간단한 소개를 입력해주세요")
                            .foregroundStyle(.where(.gray600))
                    )
                    .characterLimit(text: $descriptionFieldText, limit: Constants.descriptionCharacterLimit)
                    .focused($isFocused, equals: .description)
                    
                    if descriptionFieldText.isEmpty == false {
                        Button {
                            descriptionFieldText.removeAll()
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
                
                Text("(\(descriptionFieldText.count)/\(Constants.descriptionCharacterLimit))")
                    .foregroundStyle(.where(.gray700))
            }
            .whereFont(.body16regular)
        }
    }
    
    struct InvitationView: View {
        @State private var floaterItem: FloaterItem?
        
        private var participantsIDs: Set<UInt64> { viewModel.selectedParticipantIDs }
        
        private let viewModel: InvitationStatePerformable
        
        init(viewModel: InvitationStatePerformable) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack {
                ScrollView(.vertical) {
                    friendsSections(viewModel.friendsDataSource)
                }
                .scrollIndicators(.never)
                .floater($floaterItem) { _ in
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                }
                
                Button {
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
                    let friends = friends.filter { $0.isRecent }
                    
                    ForEach(friends.indices, id: \.self) { index in
                        Cell(
                            friend: friends[index],
                            participants: participantsIDs,
                            index: index
                        ) { index in
                            viewModel.toggleInvitationState(by: index)
                        }
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
                    ForEach(friends.indices, id: \.self) { index in
                        Cell(
                            friend: friends[index],
                            participants: participantsIDs,
                            index: index
                        ) { index in
                            viewModel.toggleInvitationState(by: index)
                        }
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
        fileprivate let dataSource: FriendCellDataSource
        private let participants: Set<UInt64>
        private let index: Int
        private let onToggle: (_ index: Int) -> Void
        
        private var isSelected: Bool {
            participants.contains(dataSource.id)
        }
    
        fileprivate init(
            friend: FriendCellDataSource,
            participants: Set<UInt64>,
            index: Int,
            onToggle: @escaping (_ index: Int) -> Void
        ) {
            self.dataSource = friend
            self.participants = participants
            self.index = index
            self.onToggle = onToggle
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
                    onToggle(index)
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
