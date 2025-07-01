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
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isContentFieldFocused
    @State private var isFloaterPresented: Bool = false
    @State private var isPopupPresented: Bool = false
    @State private var titleFieldText = String()
    @State private var contentFieldText = String()
    @State private var viewModel: EditInquiryViewModel
    
    private var disabled: Bool {
        titleFieldText.isEmpty || contentFieldText.isEmpty || viewModel.isProcessing
    }
    
    private let inquiry: Inquiry?
    
    init(inquiry: Inquiry?, resolver: Resolver) {
        self.inquiry = inquiry
        self.viewModel = resolver.resolve(EditInquiryViewModel.self)!
    }
    
    var body: some View {
        ScrollView(.vertical) {
            textFieldsArea
            
            AttachmentImagesSection($isPopupPresented, viewModel)
            
            Spacer()
            
            Button {
                viewModel.createInquiry(title: titleFieldText, content: contentFieldText)
            } label: {
                Text("등록")
                    .whereFont(.body16medium)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.whereRoundedProminent(disabled: disabled))
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
        .floater($isFloaterPresented, title: "잠시 후에 다시 시도해주세요.")
        .padding()
        .onTapGesture {
            isContentFieldFocused = false
        }
        .popup($isPopupPresented) {
            PopupView($isPopupPresented, viewModel)
        }
        .onAppear {
            titleFieldText = inquiry?.title ?? String()
            contentFieldText = inquiry?.title ?? String()
        }
        .onReceive(viewModel.editInquiryCompletionPublisher) { isSuccess in
            guard isSuccess else {
                return isFloaterPresented = true
            }
            dismiss()
        }
    }
    
    private var textFieldsArea: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .trailing) {
                RoundedTextField(Constants.titlePlaceholder, text: $titleFieldText, lineColor: .where(.gray200))
                    .characterLimit(text: $titleFieldText, limit: Constants.titleCharacterLimit)
                
                Text("\(titleFieldText.count)/\(Constants.titleCharacterLimit)")
                    .whereFont(.body14regular)
                    .foregroundStyle(.where(.gray500))
                    .padding(.trailing, 30)
            }
            
            ZStack(alignment: .bottomTrailing) {
                RoundedTextEditor(Constants.contentPlaceholder, text: $contentFieldText)
                    .characterLimit(text: $contentFieldText, limit: Constants.contentCharacterLimit)
                    .focused($isContentFieldFocused)
                    .frame(height: 175)
                
                Text("\(contentFieldText.count)/\(Constants.contentCharacterLimit)")
                    .whereFont(.body14regular)
                    .foregroundStyle(.where(.gray500))
                    .padding(.bottom)
                    .padding(.trailing, 30)
            }
        }
        .padding(.top, 40)
    }
}

// MARK: Nested Types
extension EditInquiryView {
    struct Constants {
        /// 제목 글자 수 제한
        static let titleCharacterLimit: Int = 15
        /// 내용 글자 수 제한
        static let contentCharacterLimit: Int = 500
        /// 제목 텍스트필드 문구
        static let titlePlaceholder: String = "제목을 입력해주세요."
        /// 내용 텍스트필드 문구
        static let contentPlaceholder: String = "내용을 자세하게 입력할수록 빠르게 답변을 받을 수 있어요."
        /// 파일 호환성 안내
        static let fileCompatibilityInformation: String = "10MB 미만의 JPG, PNG, GIF 파일만 등록가능 합니다."
        /// 첨부파일 법적처리 안내
        static let legalProcessingGuideForAttachedFiles: String = "문의와 무관한 내용이거나 음란/불법적인 내용은 통보없이 삭제될 수 있습니다."
        /// 최대 첨부사진 개수
        static let maxAttachmentImageCount: Int = 5
    }
}

// MARK: - Subviews
extension EditInquiryView {
    struct AttachmentImagesSection: View {
        @Binding var isPopupPresented: Bool
        
        private let viewModel: EditInquiryViewModel
        
        init(
            _ isPopupPresented: Binding<Bool>,
            _ viewModel: EditInquiryViewModel
        ) {
            self._isPopupPresented = isPopupPresented
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("사진첨부")
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(.where(.gray800))
                    
                    Text("참고해야하는 캡쳐 화면이 있다면 첨부해주세요. (최대 5장)")
                        .whereFont(.body14regular)
                        .foregroundStyle(.where(.gray500))
                }
                
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.imageDatas.indices, id: \.self) { index in
                            cell(index)
                        }
                    }
                }
                .scrollIndicators(.never)
                .frame(height: 80)
                
                VStack(alignment: .leading, spacing: .zero) {
                    Text(Constants.fileCompatibilityInformation)
                        .withBulletPoint()
                        .whereFont(.caption12regular)
                        .foregroundStyle(.where(.gray600))
                    
                    Text(Constants.legalProcessingGuideForAttachedFiles)
                        .withBulletPoint()
                        .whereFont(.caption12regular)
                        .foregroundStyle(.where(.gray600))
                }
            }
        }
        
        @ViewBuilder private func cell(_ index: Int) -> some View {
            Button {
                isPopupPresented = true
                viewModel.selectImage(at: index)
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
        @Binding var isPopupPresented: Bool
        @State private var selectedItem: PhotosPickerItem?
        @State private var isImporting: Bool = false
        
        private let viewModel: EditInquiryViewModel
        
        init(
            _ isPopupPresented: Binding<Bool>,
            _ viewModel: EditInquiryViewModel
        ) {
            self._isPopupPresented = isPopupPresented
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
                        isPopupPresented = false
                    }
                }
                
                Button {
                    isImporting = true
                } label: {
                    Text("파일 선택")
                        .padding()
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                }
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.image, .jpeg, .png, .gif, .heic, .heif]) { result in
                    switch result {
                    case .success(let url):
                        guard url.startAccessingSecurityScopedResource(),
                              let data = try? Data(contentsOf: url)
                        else { return }
                        
                        url.stopAccessingSecurityScopedResource()
                        viewModel.importImageData(data)
                        
                    case .failure(let error):
                        #if DEBUG
                        print("Error occured while importing image for edit inquiry: \(error)")
                        #endif
                    }
                }
                
                if viewModel.currentImageData != nil {
                    Button(role: .destructive) {
                        viewModel.clearImageData()
                        isPopupPresented = false
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
                        isPopupPresented = false
                    }
            }
        }
    }
}

#Preview {
    EditInquiryView(inquiry: nil, resolver: PreviewHelper.shared.resolver)
}
