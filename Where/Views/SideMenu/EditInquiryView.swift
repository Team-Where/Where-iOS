//
//  EditInquiryView.swift
//  Where
//
//  Created by Swain Yun on 3/26/25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditInquiryView: View {
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
    
    @State private var isPopupPresented: Bool = false
    @State private var selectedIndex: Int = 0
    @State private var titleFieldText: String
    @State private var contentFieldText: String
    @FocusState private var isContentFieldFocused
    @State private var images: [UIImage?] = .init(repeating: nil, count: Constants.maxAttachmentImageCount)
    
    private var disabled: Bool { titleFieldText.isEmpty || contentFieldText.isEmpty }
    
    init(inquiry: Inquiry?) {
        self.titleFieldText = inquiry?.title ?? String()
        self.contentFieldText = inquiry?.content ?? String()
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
                
                attachmentImagesSection()
                
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
            .buttonStyle(.whereRoundedProminent(disabled: disabled))
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
        .popup($isPopupPresented) {
            PopupView(isPopupPresented: $isPopupPresented, image: $images[selectedIndex])
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
        .padding()
        .padding(.top, 40)
    }
    
    @ViewBuilder private func attachmentImagesSection() -> some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(0..<5) { index in
                    AttachmentImageCell(isPopupPresented: $isPopupPresented, selectedIndex: $selectedIndex, image: $images[index], index: index)
                }
            }
        }
        .scrollIndicators(.never)
        .frame(height: 80)
    }
    
    private var guideArea: some View {
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

// MARK: Nested Types
extension EditInquiryView {
    struct AttachmentImageCell: View {
        @Binding var isPopupPresented: Bool
        @Binding var selectedIndex: Int
        @Binding var image: UIImage?
        
        let index: Int
        
        var body: some View {
            Button {
                withAnimation {
                    selectedIndex = index
                    isPopupPresented = true
                }
            } label: {
                if let image = image {
                    Image(uiImage: image)
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
        @Binding var image: UIImage?
        @State private var isImporting: Bool = false
        @State private var selectedItem: PhotosPickerItem?
        
        init(
            isPopupPresented: Binding<Bool>,
            image: Binding<UIImage?>
        ) {
            self._isPopupPresented = isPopupPresented
            self._image = image
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
                        guard let data = try? await newValue?.loadTransferable(type: Data.self),
                              let uiImage = UIImage(data: data) else { return }
                        image = uiImage
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
                // TODO: 테스트 과정에서 파일 확장자 수정할 수 있음
                .fileImporter(isPresented: $isImporting, allowedContentTypes: [.image, .jpeg, .png, .gif, .heic, .heif, .heics]) { result in
                    switch result {
                    case .success(let url):
                        guard url.startAccessingSecurityScopedResource(),
                              let data = try? Data(contentsOf: url),
                              let uiImage = UIImage(data: data)
                        else { return }
                        
                        url.stopAccessingSecurityScopedResource()
                        image = uiImage
                        
                    case .failure(let error):
                        #if DEBUG
                        print(error)
                        #endif
                    }
                }
                
                if image != nil {
                    Button(role: .destructive) {
                        image = nil
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
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        EditInquiryView(inquiry: nil)
    }
}
