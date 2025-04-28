//
//  EditProfileView.swift
//  Where
//
//  Created by Swain Yun on 3/25/25.
//

import SwiftUI
import Swinject

struct EditProfileView: View {
    @ObservedObject private var viewModel: EditProfileViewModel
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.viewModel = resolver.resolve(EditProfileViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                if let data = viewModel.profileImageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 155, height: 155)
                        .clipShape(Circle())
                }
                
                Button {
                    withAnimation {
                        viewModel.showPopup()
                    }
                } label: {
                    Image("CameraButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("닉네임")
                        .whereFont(.body14regular)
                        .foregroundStyle(.where(hex: 0x374151))
                    
                    RoundedTextField(
                        "닉네임을 입력해주세요",
                        text: $viewModel.nicknameFieldText,
                        lineColor: Color(hex: 0xE5E7EB)
                    )
                }
                
                Text(viewModel.isNicknameValid ? "사용 가능한 닉네임입니다." : "2~8자의 영문, 숫자, 한글, 특수문자(-, _)만 사용할 수 있습니다.")
                    .whereFont(.body14regular)
                    .foregroundColor(viewModel.isNicknameValid ? .green : (viewModel.nicknameFieldText.isEmpty ? .black : .red))
            }
            .padding()
            .padding(.top)
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .navigation) {
                Text("프로필 수정")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.updateProfile()
                } label: {
                    if viewModel.step == .processing {
                        ProgressView()
                    } else {
                        Text("완료")
                    }
                }
                .disabled(viewModel.isNicknameValid == false || viewModel.step == .processing)
            }
        }
        .popup($viewModel.isPopupPresented) {
            ImageSelectionPopupView(isPopupPresented: $viewModel.isPopupPresented) { data in
                viewModel.selectProfileImageData(data)
            }
        }
        .floater($viewModel.isFloaterPresented, title: "잠시 후 다시 시도해주세요.")
        .onChange(of: viewModel.step) { oldValue, newValue in
            switch newValue {
            case .beforeUpdate, .processing: break
            case .done:
                dismiss()
            case .errorOccured:
                viewModel.isFloaterPresented = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView(resolver: PreviewHelper.shared.resolver)
    }
}
