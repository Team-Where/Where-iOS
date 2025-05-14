//
//  ProfileCreationView.swift
//  Where
//
//  Created by Swain Yun on 5/2/25.
//

import SwiftUI
import Swinject

struct ProfileCreationView: View {
    @ObservedObject private var viewModel: ProfileCreationViewModel
    @Binding var isRegistrationNeeded: Bool
    @FocusState private var isFocused: Bool
    
    init(
        _ isRegistrationNeeded: Binding<Bool>,
        resolver: Resolver
    ) {
        self._isRegistrationNeeded = isRegistrationNeeded
        self.viewModel = resolver.resolve(ProfileCreationViewModel.self)!
    }
    
    var body: some View {
        content()
            .toolbar(.hidden, for: .tabBar)
            .whereForm(viewModel.navigationTitle) {
                Button {
                    viewModel.proceed()
                } label: {
                    if viewModel.isProcessing {
                        ProgressView()
                    } else {
                        Text(viewModel.proceedButtonLabel)
                            .whereFont(.body16semibold)
                    }
                }
                .frame(width: 350, height: 48)
                .buttonStyle(.whereRoundedProminent(disabled: viewModel.isProceedButtonDisabled))
                .ignoresSafeArea(.keyboard)
                .disabled(viewModel.isProcessing)
            }
            .popup($viewModel.isPopupPresented) {
                ImageSelectionPopupView(isPopupPresented: $viewModel.isPopupPresented) { data in
                    viewModel.profileImageData = data
                }
            }
            .onChange(of: viewModel.isCompleted) { _, isCompleted in
                guard isCompleted else { return }
                isRegistrationNeeded = false
            }
    }
    
    @ViewBuilder private func content() -> some View {
        switch viewModel.profileCreationStep {
        case .profile:
            ScrollView(.vertical) {
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
                            viewModel.isPopupPresented = true
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
            .scrollDismissesKeyboard(.immediately)
            .floater($viewModel.isFloaterPresented, title: "프로필 설정이 완료되지 않았어요.")
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
                text: $viewModel.nicknameFieldText,
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
            
            Text(viewModel.nicknameValidationNotice)
                .whereFont(.body14regular)
                .foregroundColor(nicknameValidationNoticeColor())
                .padding(.top, 8)
        }
    }
    
    private func textFieldLineColor(_ isFocused: Bool) -> Color {
        let isInvalid = viewModel.nicknameValidationState == .duplicated || viewModel.nicknameValidationState == .invalid
        
        guard isInvalid == false else { return .red }
        return isFocused ? .accent : Color(hex: 0xE5E7EB)
    }
    
    private func nicknameValidationNoticeColor() -> Color {
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
