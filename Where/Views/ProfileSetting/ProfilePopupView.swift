//
//  ProfileCreationPopUpView.swift
//  Where
//
//  Created by LHH on 12/30/24.
//

import SwiftUI
import PhotosUI

struct ProfilePopupView: View {
    @Binding var showPopup: Bool
    @Binding var profileImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.4)) // 배경을 어두운 반투명 색으로 설정
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Button("기본 이미지로 설정") {
                    profileImage = UIImage(named: "person")
                    showPopup = false
                }
                .padding(.top,20)
                .padding(.leading)
                .foregroundStyle(Color.black)
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("앨범에서 사진 선택")
                        .padding()
                        .foregroundStyle(Color.black)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            profileImage = uiImage
                            showPopup = false
                        }
                    }
                }
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        Text("취소")
                            .bold()
                            .foregroundStyle(Color.white)
                    )
                
                    .onTapGesture {
                        showPopup = false
                    }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(width: 300) // 팝업의 가로 크기 설정
            .shadow(radius: 10) // 그림자 효과 추가
        }
    }
}
