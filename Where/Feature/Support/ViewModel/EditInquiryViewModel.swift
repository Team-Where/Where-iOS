//
//  EditInquiryViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/28/25.
//

import Foundation
import Combine
import Swinject

@Observable
final class EditInquiryViewModel {
    var selectedIndex: Int = .zero
    
    var imageDatas = [Data?](repeating: nil, count: EditInquiryView.Constants.maxAttachmentImageCount)
    
    var currentImageData: Data? { imageDatas[selectedIndex] }
    
    var editInquiryCompletionPublisher: AnyPublisher<Bool, Never> { editInquiryCompletionSubject.eraseToAnyPublisher() }
    var imageSizeExceedsLimitPublisher: AnyPublisher<Void, Never> { imageSizeExceedsLimitSubject.eraseToAnyPublisher() }
    
    private(set) var isProcessing: Bool = false
    
    private let editInquiryCompletionSubject = PassthroughSubject<Bool, Never>()
    private let imageSizeExceedsLimitSubject = PassthroughSubject<Void, Never>()
    
    private let supportCore: SupportCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.supportCore = resolver.resolve(SupportCoreProtocol.self)!
    }
}

// MARK: - Interfaces
extension EditInquiryViewModel {
    func selectImage(at index: Int) {
        selectedIndex = index
    }
    
    func importImageData(_ data: Data) {
        // 크기 검사
        let maxImageSize = EditInquiryView.Constants.maxImageSizeLimit
        guard data.count <= maxImageSize else { return imageSizeExceedsLimitSubject.send(()) }
        imageDatas[selectedIndex] = data
    }
//    
    func clearImageData() {
        imageDatas[selectedIndex] = nil
    }
    
    func createInquiry(title: String, content: String) {
        isProcessing = true
        supportCore.createInquiry(title: title, content: content, images: imageDatas)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isProcessing = false
                
                switch completion {
                case .finished:
                    self?.editInquiryCompletionSubject.send(true)
                case .failure:
                    self?.editInquiryCompletionSubject.send(false)
                }
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: #function)
    }
}
