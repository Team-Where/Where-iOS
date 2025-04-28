//
//  EditInquiryViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/28/25.
//

import Foundation
import Combine

final class EditInquiryViewModel: ObservableObject {
    @Published var isPopupPresented: Bool = false
    @Published var selectedIndex: Int = .zero
    @Published var titleFieldText = String()
    @Published var contentFieldText = String()
    @Published var imageDatas = [Data?](repeating: nil, count: Constants.maxAttachmentImageCount)
    @Published var isImporting: Bool = false
    
    var currentImageData: Data? { imageDatas[selectedIndex] }
    
    var disabled: Bool {
        titleFieldText.isEmpty || contentFieldText.isEmpty
    }
    
    private let supportCore: SupportCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(supportCore: SupportCoreProtocol) {
        self.supportCore = supportCore
    }
}

// MARK: - Nested Types
extension EditInquiryViewModel {
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

// MARK: - Interfaces
extension EditInquiryViewModel {
    func onAppear(_ inquiry: Inquiry?) {
        titleFieldText = inquiry?.title ?? String()
        contentFieldText = inquiry?.content ?? String()
    }
    
    func onDisappear() {
        isPopupPresented = false
        selectedIndex = .zero
        titleFieldText.removeAll()
        contentFieldText.removeAll()
        imageDatas = .init(repeating: nil, count: Constants.maxAttachmentImageCount)
    }
    
    func presentPopup(_ index: Int) {
        selectedIndex = index
        isPopupPresented = true
    }
    
    func dismissPopup() {
        isPopupPresented = false
    }
    
    func importImageData(_ data: Data) {
        imageDatas[selectedIndex] = data
        isPopupPresented = false
    }
    
    func clearImageData() {
        imageDatas[selectedIndex] = nil
        isPopupPresented = false
    }
}
