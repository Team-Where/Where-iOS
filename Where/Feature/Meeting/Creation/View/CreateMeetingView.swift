//
//  CreateMeetingView.swift
//  Where
//
//  Created by Swain Yun on 3/27/25.
//

import SwiftUI
import Swinject

struct CreateMeetingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: CreateMeetingViewModel
    @State private var step: MeetingCreationStep = .basicInformation
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.viewModel = resolver.resolve(CreateMeetingViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        VStack {
            dismissButton
            
            Spacer()
            
            header
            content(step)
                .padding(.top)
            
            Spacer()
        }
        .padding()
        .popup($viewModel.isPopupPresented) {
            ImageSelectionPopupView(isPopupPresented: $viewModel.isPopupPresented) { uiImage in
                viewModel.selectedImage = uiImage
            }
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
                Text("새 모임 만들기(\(step.turn)/2)")
                    .whereFont(.body14medium)
                    .foregroundStyle(.accent)
                
                Text(step.navigationTitle)
                    .whereFont(.title24semibold)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder private func content(_ step: MeetingCreationStep) -> some View {
        switch step {
        case .basicInformation:
            BasicInformationView(
                isPopupPresented: $viewModel.isPopupPresented,
                step: $step,
                tempInfo: $viewModel.tempMeetingInfo,
                image: $viewModel.selectedImage
            )
        case .inviteFriends:
            InviteFriendsView(
                step: $step,
                tempMeetingInfo: $viewModel.tempMeetingInfo
            )
        }
    }
}

// MARK: Nested Types
extension CreateMeetingView {
    /// 모임 생성 단계
    enum MeetingCreationStep: Int {
        /// 기본 정보 설정 단계
        case basicInformation = 1
        /// 친구 초대 단계
        case inviteFriends
        
        var turn: Int { self.rawValue }
        
        var navigationTitle: String {
            switch self {
            case .basicInformation: "어떤 모임인가요?"
            case .inviteFriends: "파티원을 초대해요!"
            }
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
        
        @Binding var step: MeetingCreationStep
        @Binding var tempMeetingInfo: TemporaryMeetingInfo?
        @Binding var isPopupPresented: Bool
        @Binding var selectedImage: UIImage?
        @State private var isFloaterPresented: Bool = false
        @State private var title: String = String()
        @State private var description: String = String()
        @FocusState private var isFocused: TextFieldFocusState?
        
        init(
            isPopupPresented: Binding<Bool>,
            step: Binding<MeetingCreationStep>,
            tempInfo temp: Binding<TemporaryMeetingInfo?>,
            image: Binding<UIImage?>
        ) {
            self._isPopupPresented = isPopupPresented
            self._step = step
            self._tempMeetingInfo = temp
            self._selectedImage = image
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
                    // 임시 모임 정보 기록 후 다음 단계 진행
                    tempMeetingInfo = tempMeetingInfo?
                        .setBasicInfo(title: title, description: description, image: selectedImage)
                    step = .inviteFriends
                } label: {
                    Text("다음")
                        .whereFont(.body16medium)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.whereRoundedProminent(disabled: title.isEmpty))
            }
            .clipShape(.rect)
            .onTapGesture {
                isFocused = nil
            }
            .onAppear {
                isFloaterPresented = true
            }
        }
        
        private var profileImageSection: some View {
            Button {
                withAnimation {
                    isPopupPresented = true
                }
            } label: {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(.rect(cornerRadius: 16))
                } else {
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
                }
            }
        }
        
        @ViewBuilder private var textFieldSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    TextField(
                        "",
                        text: $title,
                        prompt: Text(verbatim: "모임이름을 입력해주세요")
                            .foregroundStyle(.where(.gray600))
                    )
                    .characterLimit(text: $title, limit: Constants.titleCharacterLimit)
                    .focused($isFocused, equals: .title)
                    
                    if title.isEmpty == false {
                        Button {
                            title.removeAll()
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
                
                Text("(\(title.count)/\(Constants.titleCharacterLimit))")
                    .foregroundStyle(.where(.gray700))
            }
            .whereFont(.body16regular)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    TextField(
                        "",
                        text: $description,
                        prompt: Text(verbatim: "모임에 대한 간단한 소개를 입력해주세요")
                            .foregroundStyle(.where(.gray600))
                    )
                    .characterLimit(text: $description, limit: Constants.descriptionCharacterLimit)
                    .focused($isFocused, equals: .description)
                    
                    if description.isEmpty == false {
                        Button {
                            description.removeAll()
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
                
                Text("(\(description.count)/\(Constants.descriptionCharacterLimit))")
                    .foregroundStyle(.where(.gray700))
            }
            .whereFont(.body16regular)
        }
    }
    
    struct InviteFriendsView: View {
        @Binding var step: MeetingCreationStep
        @Binding var tempMeetingInfo: TemporaryMeetingInfo?
        @State private var floaterItem: FloaterItem?
        @State private var friends: [User] = [
            .init(id: 0, nickname: "죠니월드"),
            .init(id: 1, nickname: "이초홍"),
            .init(id: 2, nickname: "유저2"),
            .init(id: 3, nickname: "유저3"),
        ]
        
        var body: some View {
            VStack {
                ScrollView(.vertical) {
                    friendsSections(friends)
                }
                .scrollIndicators(.never)
                .floater($floaterItem) { _ in
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                }
                
                Button {
                    // 임시 모임 정보 기록 후 다음 단계 진행
                    tempMeetingInfo = tempMeetingInfo?
                        .setInvitedFriends(friends.map({ $0.id }))
                } label: {
                    Text("다음")
                        .whereFont(.body16medium)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.whereRoundedProminent())
            }
        }
        
        @ViewBuilder private func friendsSections(_ friends: [User]) -> some View {
            Section {
                LazyVStack(spacing: 16) {
                    ForEach(friends) { friend in
                        Cell($floaterItem, friend)
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
                        Cell($floaterItem, friend)
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
extension CreateMeetingView.InviteFriendsView {
    enum FloaterItem: FloaterContent {
        case invite(friend: User)
        
        var title: String {
            switch self {
            case .invite(let friend): return "'\(friend.nickname)'님을 초대했습니다."
            }
        }
    }
    
    struct Cell: View {
        @Binding var floaterItem: FloaterItem?
        @State private var isSelected: Bool = false
        
        let friend: User
        
        init(
            _ floaterItem: Binding<FloaterItem?>,
            _ friend: User
        ) {
            self._floaterItem = floaterItem
            self.friend = friend
        }
        
        var body: some View {
            HStack(spacing: 12) {
                AsyncImage(url: friend.imageURL) { image in
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
                    Text(friend.nickname)
                        .whereFont(.body16medium)
                        .foregroundStyle(.where(.gray800))
                    
                    // TODO: 만난 횟수 표시하기 위해 '친구' 도메인 모델 선언 필요
                    Text("\(3)번 만남")
                        .whereFont(.caption11regular)
                        .foregroundStyle(.where(.gray400))
                }
                
                Spacer()
                
                Button {
                    if isSelected == false {
                        floaterItem = .invite(friend: friend)
                    }
                    
                    isSelected.toggle()
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

#Preview {
    NavigationStack {
        CreateMeetingView(resolver: PreviewHelper.shared.resolver)
    }
}
