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
    
    private let supportCore: SupportCoreProtocol
    private let cancellbleBag = CancellableBag()
    
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
        imageDatas[selectedIndex] = data
    }
//    
    func clearImageData() {
        imageDatas[selectedIndex] = nil
    }
}
