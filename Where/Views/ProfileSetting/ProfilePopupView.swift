//
//  ProfileCreationPopUpView.swift
//  Where
//
//  Created by LHH on 12/30/24.
//

import SwiftUI
import PhotosUI

struct ProfilePopupView: View {
    @Binding var isPopupPresented: Bool
    @State private var selectedItem: PhotosPickerItem?
    let onSelected: (UIImage) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            Button("기본 이미지로 설정") {
                guard let defaultImage = UIImage(named: "person") else { return }
                onSelected(defaultImage)
                isPopupPresented = false
            }
            
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("앨범에서 사진 선택")
            }
            .onChange(of: selectedItem) { oldItem, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        onSelected(uiImage)
                        isPopupPresented = false
                    }
                }
            }
            
            Button {
                isPopupPresented = false
            } label: {
                Text("취소")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.where(.gray400))
                    )
            }
        }
        .padding()
        .foregroundStyle(.black)
    }
}
