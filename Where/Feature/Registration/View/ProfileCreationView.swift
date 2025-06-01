//
//  ProfileCreationView.swift
//  Where
//
//  Created by Swain Yun on 5/2/25.
//

import SwiftUI
import Swinject

struct ProfileCreationView: View {
    @Binding var isRegistrationNeeded: Bool
    @FocusState private var isFocused: Bool
    @State private var nicknameFieldText = String()
    @State private var isPopupPresented: Bool = false
    @State private var isFloaterPresented: Bool = false
    
    private var navigationTitle: String {
        switch viewModel.profileCreationStep {
        case .profile:
            "프로필을 설정해주세요"
        case .completed:
            "\(nicknameFieldText)님,\n회원가입을 축하합니다!"
        }
    }
    
    private var isProceedButtonDisabled: Bool {
        switch viewModel.profileCreationStep {
        case .profile: return viewModel.nicknameValidationState != .valid
        case .completed: return false
        }
    }
    
    private var proceedButtonLabel: String {
        viewModel.profileCreationStep == .completed ? "완료" : "다음"
    }
    
    private var nicknameValidationNotice: String {
        switch viewModel.nicknameValidationState {
        case .valid: "사용 가능한 닉네임입니다."
        case .invalid, .beforeValidate: "2~8자의 영문, 숫자, 한글, 특수문자(-, _)만 사용할 수 있습니다."
        case .duplicated: "이미 사용 중인 닉네임입니다."
        }
    }
    
    private let viewModel: ProfileCreationViewModel
    
    init(
        _ isRegistrationNeeded: Binding<Bool>,
        resolver: Resolver
    ) {
        self._isRegistrationNeeded = isRegistrationNeeded
        self.viewModel = resolver.resolve(ProfileCreationViewModel.self)!
    }
    
    var body: some View {
        ScrollView(.vertical) {
            content()
        }
        .toolbar(.hidden, for: .tabBar)
        .whereForm(navigationTitle) {
            Button {
                proceed()
            } label: {
                if viewModel.isProcessing {
                    ProgressView()
                } else {
                    Text(proceedButtonLabel)
                        .whereFont(.body16semibold)
                        .frame(width: 350, height: 48)
                }
            }
            .buttonStyle(.whereRoundedProminent(disabled: isProceedButtonDisabled))
            .ignoresSafeArea(.keyboard)
            .disabled(viewModel.isProcessing)
        }
        .popup($isPopupPresented) {
            ImageSelectionPopupView(isPopupPresented: $isPopupPresented) { data in
                viewModel.setImageData(data)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: viewModel.isErrorOccured, onErrorOccured)
    }
    
    @ViewBuilder private func content() -> some View {
        switch viewModel.profileCreationStep {
        case .profile:
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    if let data = viewModel.profileImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 155, height: 155)
                            .clipShape(Circle())
                    } else {
                        AsyncImage(url: viewModel.socialUser?.imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 155, height: 155)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(.person)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 155, height: 155)
                                .clipShape(Circle())
                        }
                    }
                    
                    Button {
                        withAnimation {
                            isPopupPresented = true
                        }
                    } label: {
                        Image("CameraButton")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 58)
                
                nicknameCell()
            }
            .floater($isFloaterPresented, title: "프로필 설정이 완료되지 않았어요.")
        case .completed:
            VStack {
                Image("SignUpCharacter")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 274.85, height: 264)
                    .padding(.top, 40)
            }
        }
    }
    
    @ViewBuilder private func nicknameCell() -> some View {
        VStack(alignment: .leading) {
            Text("닉네임")
                .whereFont(.body14regular)
                .foregroundStyle(.where(.gray700))
                .padding(.top, 38)
            
            RoundedTextField(
                "닉네임을 입력해주세요",
                text: $nicknameFieldText,
                lineColor: textFieldLineColor(isFocused)
            )
            .foregroundStyle(Color(hex: 0x6B7280))
            .background(
                ZStack(alignment: .trailing) {
                    HStack {
                        Spacer()
                        
                        if viewModel.nicknameValidationState == .valid {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .padding(.trailing, 30)
                        }
                    }
                }
            )
            .onChange(of: nicknameFieldText, onNicknameChange)
            
            Text(nicknameValidationNotice)
                .whereFont(.body14regular)
                .foregroundColor(nicknameValidationNoticeColor())
                .padding(.top, 8)
        }
    }
}

// MARK: - Methods
private extension ProfileCreationView {
    func proceed() {
        guard isProceedButtonDisabled == false else { return }
        
        switch viewModel.profileCreationStep {
        case .profile:
            viewModel.setUpProfile(nicknameFieldText)
        case .completed:
            isRegistrationNeeded = false
        }
    }
    
    func onNicknameChange(_ before: String, _ after: String) {
        guard before != after else { return }
        viewModel.validateNickname(after)
    }
    
    func onErrorOccured(_ : Bool, _ isErrorOccured: Bool) {
        guard isErrorOccured else { return }
        isFloaterPresented = true
    }
    
    func textFieldLineColor(_ isFocused: Bool) -> Color {
        let isInvalid = viewModel.nicknameValidationState == .duplicated || viewModel.nicknameValidationState == .invalid
        
        guard isInvalid == false else { return .red }
        return isFocused ? .accent : Color(hex: 0xE5E7EB)
    }
    
    func nicknameValidationNoticeColor() -> Color {
        switch viewModel.nicknameValidationState {
        case .valid: .green
        case .beforeValidate: .where(.gray700)
        case .invalid, .duplicated: .red
        }
    }
}

#Preview {
    NavigationStack {
        ProfileCreationView(.constant(true), resolver: PreviewHelper.shared.resolver)
    }
}
