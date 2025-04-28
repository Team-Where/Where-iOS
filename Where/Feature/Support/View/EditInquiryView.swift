//
//  EditInquiryView.swift
//  Where
//
//  Created by Swain Yun on 3/26/25.
//

import SwiftUI
import Swinject
import PhotosUI
import UniformTypeIdentifiers

struct EditInquiryView: View {
    @ObservedObject private var viewModel: EditInquiryViewModel
    @FocusState private var isContentFieldFocused
    
    private let inquiry: Inquiry?
    
    init(inquiry: Inquiry?, resolver: Resolver) {
        self.inquiry = inquiry
        self.viewModel = resolver.resolve(EditInquiryViewModel.self)!
    }
    
    var body: some View {
        ScrollView(.vertical) {
            textFieldsArea
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("사진첨부")
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(.where(.gray800))
                    
                    Text("참고해야하는 캡쳐 화면이 있다면 첨부해주세요. (최대 5장)")
                        .whereFont(.body14regular)
                        .foregroundStyle(.where(.gray500))
                }
                
                AttachmentImagesSection(viewModel: viewModel)
                
                guideArea
            }
            .padding()
            
            Spacer()
            
            Button {
                // TODO: 문의 작성/수정 기능 연결
            } label: {
                Text("등록")
                    .whereFont(.body16medium)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.whereRoundedProminent(disabled: viewModel.disabled))
            .padding()
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("문의 작성")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
        }
        .onTapGesture {
            isContentFieldFocused = false
        }
        .popup($viewModel.isPopupPresented) {
            PopupView(viewModel: viewModel)
        }
        .onAppear { viewModel.onAppear(inquiry) }
        .onDisappear { viewModel.onDisappear() }
    }
    
    private var textFieldsArea: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .trailing) {
                RoundedTextField(EditInquiryViewModel.Constants.titlePlaceholder, text: $viewModel.titleFieldText, lineColor: .where(.gray200))
                    .characterLimit(text: $viewModel.titleFieldText, limit: EditInquiryViewModel.Constants.titleCharacterLimit)
                
                Text("\(viewModel.titleFieldText.count)/\(EditInquiryViewModel.Constants.titleCharacterLimit)")
                    .whereFont(.body14regular)
                    .foregroundStyle(.where(.gray500))
                    .padding(.trailing, 30)
            }
            
            ZStack(alignment: .bottomTrailing) {
                RoundedTextEditor(EditInquiryViewModel.Constants.contentPlaceholder, text: $viewModel.contentFieldText)
                    .characterLimit(text: $viewModel.contentFieldText, limit: EditInquiryViewModel.Constants.contentCharacterLimit)
                    .focused($isContentFieldFocused)
                    .frame(height: 175)
                
                Text("\(viewModel.contentFieldText.count)/\(EditInquiryViewModel.Constants.contentCharacterLimit)")
                    .whereFont(.body14regular)
                    .foregroundStyle(.where(.gray500))
                    .padding(.bottom)
                    .padding(.trailing, 30)
            }
        }
        .padding()
        .padding(.top, 40)
    }
    
    private var guideArea: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(EditInquiryViewModel.Constants.fileCompatibilityInformation)
                .withBulletPoint()
                .whereFont(.caption12regular)
                .foregroundStyle(.where(.gray600))
            
            Text(EditInquiryViewModel.Constants.legalProcessingGuideForAttachedFiles)
                .withBulletPoint()
                .whereFont(.caption12regular)
                .foregroundStyle(.where(.gray600))
        }
    }
}

// MARK: Nested Types
extension EditInquiryView {
    struct AttachmentImagesSection: View {
        @ObservedObject private var viewModel: EditInquiryViewModel
        
        init(viewModel: EditInquiryViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(viewModel.imageDatas.indices, id: \.self) { index in
                        cell(index)
                    }
                }
            }
            .scrollIndicators(.never)
            .frame(height: 80)
        }
        
        @ViewBuilder private func cell(_ index: Int) -> some View {
            Button {
                withAnimation {
                    viewModel.presentPopup(index)
                }
            } label: {
                if let data = viewModel.imageDatas[index],
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(.rect(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                        .strokeBorder(.where(.gray200))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "plus")
                                .frame(width: 12, height: 12)
                                .foregroundStyle(.where(hex: 0xADB5BD))
                        }
                }
            }
        }
    }
    
    struct PopupView: View {
        @ObservedObject private var viewModel: EditInquiryViewModel
        @State private var selectedItem: PhotosPickerItem?
        
        init(viewModel: EditInquiryViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("앨범에서 사진 선택")
                        .padding()
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                }
                .onChange(of: selectedItem) { oldValue, newValue in
                    Task {
                        guard let data = try? await newValue?.loadTransferable(type: Data.self) else { return }
                        viewModel.importImageData(data)
                    }
                }
                
                Button {
                    viewModel.isImporting = true
                } label: {
                    Text("파일 선택")
                        .padding()
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                }
                // TODO: 테스트 과정에서 파일 확장자 수정할 수 있음
                .fileImporter(isPresented: $viewModel.isImporting, allowedContentTypes: [.image, .jpeg, .png, .gif, .heic, .heif]) { result in
                    switch result {
                    case .success(let url):
                        guard url.startAccessingSecurityScopedResource(),
                              let data = try? Data(contentsOf: url)
                        else { return }
                        
                        url.stopAccessingSecurityScopedResource()
                        viewModel.importImageData(data)
                        
                    case .failure(let error):
                        #if DEBUG
                        print(error)
                        #endif
                    }
                }
                
                if viewModel.currentImageData != nil {
                    Button(role: .destructive) {
                        viewModel.clearImageData()
                    } label: {
                        Text("파일 첨부 해제")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(.rect)
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
                        viewModel.dismissPopup()
                    }
            }
            .padding()
        }
    }
}
